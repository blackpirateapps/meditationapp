import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'audio_constants.dart';

class AppAudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();
  final AudioPlayer _previewPlayer = AudioPlayer();

  AudioSession? _audioSession;
  Timer? _fadeTimer;
  bool _isInitialized = false;

  AudioPlayer get bgPlayer => _bgPlayer;
  AudioPlayer get bellPlayer => _bellPlayer;
  AudioPlayer get previewPlayer => _previewPlayer;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _audioSession = await AudioSession.instance;
      await _audioSession?.configure(const AudioSessionConfiguration.music());

      // Listen for interruptions (e.g. phone calls, audio focus changes)
      _audioSession?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _bgPlayer.setVolume(_bgPlayer.volume * 0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _bgPlayer.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Restore volume
              _bgPlayer.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              _bgPlayer.play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Audio session init error: $e');
    }
  }

  // --- Background Looping Sound with Optional Fade In ---
  Future<void> startBackgroundSound({
    required String soundId,
    required double targetVolume,
    int fadeInSeconds = 0,
  }) async {
    await stopPreview();
    _fadeTimer?.cancel();

    if (soundId == 'none' || soundId.isEmpty) {
      await _bgPlayer.stop();
      return;
    }

    final sound = AudioConstants.getSoundById(soundId);
    if (sound.assetPath.isEmpty) {
      await _bgPlayer.stop();
      return;
    }

    try {
      await _audioSession?.setActive(true);
      await _bgPlayer.setAsset(sound.assetPath);
      await _bgPlayer.setLoopMode(LoopMode.one);

      if (fadeInSeconds > 0) {
        await _bgPlayer.setVolume(0.0);
        unawaited(_bgPlayer.play());
        _fadeIn(targetVolume, fadeInSeconds);
      } else {
        await _bgPlayer.setVolume(targetVolume);
        unawaited(_bgPlayer.play());
      }
    } catch (e) {
      debugPrint('Error starting background sound: $e');
    }
  }

  void _fadeIn(double targetVolume, int seconds) {
    _fadeTimer?.cancel();
    final steps = seconds * 10;
    if (steps <= 0) {
      _bgPlayer.setVolume(targetVolume);
      return;
    }
    final stepDuration = const Duration(milliseconds: 100);
    final increment = targetVolume / steps;
    int currentStep = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final vol = (increment * currentStep).clamp(0.0, targetVolume);
      _bgPlayer.setVolume(vol);
      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }

  // --- Fade Out Background Sound ---
  Future<void> fadeOutBackgroundSound({int fadeOutSeconds = 3}) async {
    _fadeTimer?.cancel();
    if (!_bgPlayer.playing) return;

    final initialVolume = _bgPlayer.volume;
    final steps = fadeOutSeconds * 10;
    if (steps <= 0) {
      await _bgPlayer.stop();
      return;
    }

    final stepDuration = const Duration(milliseconds: 100);
    final decrement = initialVolume / steps;
    int currentStep = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      currentStep++;
      final vol = (initialVolume - (decrement * currentStep)).clamp(0.0, initialVolume);
      await _bgPlayer.setVolume(vol);
      if (currentStep >= steps || vol <= 0.01) {
        timer.cancel();
        await _bgPlayer.stop();
      }
    });
  }

  Future<void> pauseBackgroundSound() async {
    _fadeTimer?.cancel();
    await _bgPlayer.pause();
  }

  Future<void> resumeBackgroundSound() async {
    await _audioSession?.setActive(true);
    unawaited(_bgPlayer.play());
  }

  Future<void> stopBackgroundSound() async {
    _fadeTimer?.cancel();
    await _bgPlayer.stop();
  }

  Future<void> setBackgroundVolume(double volume) async {
    await _bgPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  // --- Bell Sounds (one-shot without interrupting background audio) ---
  Future<void> playBell(String soundId, {double volume = 0.8}) async {
    if (soundId == 'none' || soundId.isEmpty) return;
    final sound = AudioConstants.getSoundById(soundId);
    if (sound.assetPath.isEmpty) return;

    try {
      await _bellPlayer.stop();
      await _bellPlayer.setAsset(sound.assetPath);
      await _bellPlayer.setLoopMode(LoopMode.off);
      await _bellPlayer.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_bellPlayer.play());
    } catch (e) {
      debugPrint('Error playing bell sound: $e');
    }
  }

  // --- Sound Preview in Settings / Practice Editor (Section 66) ---
  Future<void> playPreview(String soundId, {double volume = 0.6, bool isBell = false}) async {
    if (_bgPlayer.playing) return; // Do not overlap with active session

    await stopPreview();
    if (soundId == 'none' || soundId.isEmpty) return;

    final sound = AudioConstants.getSoundById(soundId);
    if (sound.assetPath.isEmpty) return;

    try {
      await _previewPlayer.setAsset(sound.assetPath);
      await _previewPlayer.setLoopMode(isBell ? LoopMode.off : LoopMode.one);
      await _previewPlayer.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_previewPlayer.play());
    } catch (e) {
      debugPrint('Error playing preview: $e');
    }
  }

  Future<void> stopPreview() async {
    if (_previewPlayer.playing) {
      await _previewPlayer.stop();
    }
  }

  bool get isPreviewPlaying => _previewPlayer.playing;

  Future<void> stopAll() async {
    _fadeTimer?.cancel();
    await _bgPlayer.stop();
    await _bellPlayer.stop();
    await _previewPlayer.stop();
    try {
      await _audioSession?.setActive(false);
    } catch (_) {}
  }

  void dispose() {
    _fadeTimer?.cancel();
    _bgPlayer.dispose();
    _bellPlayer.dispose();
    _previewPlayer.dispose();
  }
}
