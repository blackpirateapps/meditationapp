import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/meditation_type.dart';
import '../../../data/models/practice.dart';
import '../../../data/models/session_snapshot.dart';
import '../../../data/models/meditation_session.dart';
import '../../../data/repositories/practice_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptics/haptic_service.dart';
import '../../../core/wakelock/wakelock_service.dart';

enum SessionState {
  preparing,
  active,
  paused,
  completed,
  cancelled,
}

enum BreathingPhase {
  inhale,
  inhaleHold,
  exhale,
  exhaleHold;

  String get label {
    switch (this) {
      case BreathingPhase.inhale:
        return 'Inhale';
      case BreathingPhase.inhaleHold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Exhale';
      case BreathingPhase.exhaleHold:
        return 'Hold';
    }
  }
}

class SessionController extends ChangeNotifier {
  final Practice practice;
  final PracticeRepository practiceRepo;
  final SessionRepository sessionRepo;
  final AchievementRepository achievementRepo;
  final AppAudioService audioService;

  late final SessionSnapshot snapshot;
  final String sessionId = const Uuid().v4();

  SessionState _state = SessionState.preparing;
  SessionState get state => _state;

  DateTime? _sessionStartTime;
  DateTime? _actualStartTime;
  DateTime? _lastResumeTime;
  Duration _accumulatedActiveDuration = Duration.zero;

  int _prepSecondsRemaining = 0;
  int get prepSecondsRemaining => _prepSecondsRemaining;

  int _elapsedSeconds = 0;
  int get elapsedSeconds => _elapsedSeconds;

  int get remainingSeconds {
    final rem = practice.durationSeconds - _elapsedSeconds;
    return rem < 0 ? 0 : rem;
  }

  double get progress {
    if (practice.durationSeconds <= 0) return 0.0;
    return (_elapsedSeconds / practice.durationSeconds).clamp(0.0, 1.0);
  }

  // Breathing Engine State
  BreathingPhase _currentBreathingPhase = BreathingPhase.inhale;
  BreathingPhase get currentBreathingPhase => _currentBreathingPhase;
  double _breathingPhaseProgress = 0.0; // 0.0 to 1.0 for current phase
  double get breathingPhaseProgress => _breathingPhaseProgress;

  // Body Scan Engine State
  int _currentBodyScanIndex = 0;
  int get currentBodyScanIndex => _currentBodyScanIndex;

  // Mantra Engine State
  bool _mantraPulse = false;
  bool get mantraPulse => _mantraPulse;

  // Walking Engine State
  int _currentWalkingPhaseIndex = 0;
  int get currentWalkingPhaseIndex => _currentWalkingPhaseIndex;

  // Display State
  bool _controlsVisible = false;
  bool get controlsVisible => _controlsVisible;

  bool _isDimmed = false;
  bool get isDimmed => _isDimmed;

  Timer? _ticker;
  int _lastIntervalBellMinute = 0;

  SessionController({
    required this.practice,
    required this.practiceRepo,
    required this.sessionRepo,
    required this.achievementRepo,
    required this.audioService,
  }) {
    snapshot = practice.toSnapshot();
    _prepSecondsRemaining = practice.preparationSeconds;
    _isDimmed = practice.type == MeditationType.sleep;
  }

  Future<void> start() async {
    _sessionStartTime = DateTime.now();

    // Setup Wakelock
    await WakelockService.applyBehavior(practice.screenBehavior);

    // If preparation time is configured
    if (_prepSecondsRemaining > 0) {
      _state = SessionState.preparing;
      _startPrepTimer();
    } else {
      await _startActiveMeditation();
    }
    notifyListeners();
  }

  void _startPrepTimer() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_prepSecondsRemaining > 1) {
        _prepSecondsRemaining--;
        HapticService.selection(enabled: practice.hapticGuidance);
        notifyListeners();
      } else {
        _prepSecondsRemaining = 0;
        timer.cancel();
        await _startActiveMeditation();
      }
    });
  }

  Future<void> _startActiveMeditation() async {
    _state = SessionState.active;
    _actualStartTime = DateTime.now();
    _lastResumeTime = DateTime.now();

    // Haptics & Start Bell
    HapticService.sessionStart(enabled: practice.hapticGuidance);
    if (practice.startSoundEnabled && practice.startSound != 'none') {
      await audioService.playBell(practice.startSound);
    }

    // Start background looping sound with fade in
    if (practice.backgroundSound != 'none') {
      await audioService.startBackgroundSound(
        soundId: practice.backgroundSound,
        targetVolume: practice.backgroundSoundVolume,
        fadeInSeconds: practice.fadeInSeconds,
      );
    }

    _startSessionClock();
    notifyListeners();
  }

  void _startSessionClock() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state != SessionState.active) return;

      final now = DateTime.now();
      final currentLeg = _lastResumeTime != null
          ? now.difference(_lastResumeTime!)
          : Duration.zero;
      final totalActive = _accumulatedActiveDuration + currentLeg;
      final newElapsedSeconds = totalActive.inSeconds;

      if (newElapsedSeconds != _elapsedSeconds) {
        _elapsedSeconds = newElapsedSeconds;
        _onSecondElapsed();
      }

      _updatePhaseEngines(totalActive);
      notifyListeners();

      // Check Completion
      if (_elapsedSeconds >= practice.durationSeconds) {
        _completeSession();
      }
    });
  }

  void _onSecondElapsed() {
    // 1. Interval Bells
    if (practice.intervalBellEnabled &&
        practice.intervalBellIntervalSeconds > 0 &&
        _elapsedSeconds > 0) {
      if (_elapsedSeconds % practice.intervalBellIntervalSeconds == 0) {
        final currentMarker = _elapsedSeconds ~/ practice.intervalBellIntervalSeconds;
        if (currentMarker != _lastIntervalBellMinute) {
          _lastIntervalBellMinute = currentMarker;
          HapticService.medium(enabled: practice.hapticGuidance);
          audioService.playBell(
            practice.intervalBellSound,
            volume: practice.intervalBellVolume,
          );
        }
      }
    }

    // 2. Sleep mode fade-out near completion
    if (practice.type == MeditationType.sleep && practice.fadeOutSeconds > 0) {
      final secondsLeft = practice.durationSeconds - _elapsedSeconds;
      if (secondsLeft == practice.fadeOutSeconds) {
        audioService.fadeOutBackgroundSound(
          fadeOutSeconds: practice.fadeOutSeconds,
        );
      }
    }
  }

  void _updatePhaseEngines(Duration totalActive) {
    // 1. Breathing Engine
    if (practice.type == MeditationType.breathing &&
        practice.breathingConfig != null) {
      final config = practice.breathingConfig!;
      final cycleDuration = config.cycleDurationSeconds;
      if (cycleDuration > 0) {
        final cycleElapsedMs =
            totalActive.inMilliseconds % (cycleDuration * 1000);
        final cycleElapsedSec = cycleElapsedMs / 1000.0;

        final inhaleEnd = config.inhaleSeconds.toDouble();
        final inhaleHoldEnd = inhaleEnd + config.inhaleHoldSeconds;
        final exhaleEnd = inhaleHoldEnd + config.exhaleSeconds;

        BreathingPhase newPhase;
        double progress;

        if (cycleElapsedSec < inhaleEnd) {
          newPhase = BreathingPhase.inhale;
          progress = cycleElapsedSec / (config.inhaleSeconds > 0 ? config.inhaleSeconds : 1);
        } else if (cycleElapsedSec < inhaleHoldEnd) {
          newPhase = BreathingPhase.inhaleHold;
          progress = (cycleElapsedSec - inhaleEnd) /
              (config.inhaleHoldSeconds > 0 ? config.inhaleHoldSeconds : 1);
        } else if (cycleElapsedSec < exhaleEnd) {
          newPhase = BreathingPhase.exhale;
          progress = (cycleElapsedSec - inhaleHoldEnd) /
              (config.exhaleSeconds > 0 ? config.exhaleSeconds : 1);
        } else {
          newPhase = BreathingPhase.exhaleHold;
          progress = (cycleElapsedSec - exhaleEnd) /
              (config.exhaleHoldSeconds > 0 ? config.exhaleHoldSeconds : 1);
        }

        if (newPhase != _currentBreathingPhase) {
          _currentBreathingPhase = newPhase;
          HapticService.breathPhase(enabled: practice.hapticGuidance);
        }
        _breathingPhaseProgress = progress.clamp(0.0, 1.0);
      }
    }

    // 2. Body Scan Engine
    if (practice.type == MeditationType.bodyScan &&
        practice.bodyScanConfig != null) {
      final parts = practice.bodyScanConfig!.bodyParts;
      if (parts.isNotEmpty) {
        final secPerPart = practice.durationSeconds / parts.length;
        final newIndex = (_elapsedSeconds / secPerPart).floor().clamp(0, parts.length - 1);
        if (newIndex != _currentBodyScanIndex) {
          _currentBodyScanIndex = newIndex;
          HapticService.light(enabled: practice.hapticGuidance);
        }
      }
    }

    // 3. Mantra Engine
    if (practice.type == MeditationType.mantra &&
        practice.mantraConfig != null) {
      final interval = practice.mantraConfig!.intervalSeconds;
      if (interval > 0) {
        final sec = _elapsedSeconds % interval;
        _mantraPulse = sec < 3; // pulse for 3 seconds
      }
    }

    // 4. Walking Engine
    if (practice.type == MeditationType.walking &&
        practice.walkingConfig != null) {
      final phases = practice.walkingConfig!.walkingPhases;
      if (phases.isNotEmpty) {
        final secPerPhase = practice.durationSeconds / phases.length;
        final newIndex =
            (_elapsedSeconds / secPerPhase).floor().clamp(0, phases.length - 1);
        if (newIndex != _currentWalkingPhaseIndex) {
          _currentWalkingPhaseIndex = newIndex;
          HapticService.medium(enabled: practice.hapticGuidance);
        }
      }
    }
  }

  // --- User Controls ---
  Future<void> pause() async {
    if (_state != SessionState.active) return;
    _state = SessionState.paused;

    final now = DateTime.now();
    if (_lastResumeTime != null) {
      _accumulatedActiveDuration += now.difference(_lastResumeTime!);
      _lastResumeTime = null;
    }
    _ticker?.cancel();
    await audioService.pauseBackgroundSound();
    HapticService.selection(enabled: practice.hapticGuidance);
    notifyListeners();
  }

  Future<void> resume() async {
    if (_state != SessionState.paused) return;
    _state = SessionState.active;
    _lastResumeTime = DateTime.now();

    await audioService.resumeBackgroundSound();
    _startSessionClock();
    HapticService.selection(enabled: practice.hapticGuidance);
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _state = SessionState.completed;
    _ticker?.cancel();

    // Ending Bell & Haptics
    HapticService.sessionEnd(enabled: practice.hapticGuidance);
    if (practice.endingSoundEnabled && practice.endingSound != 'none') {
      await audioService.playBell(practice.endingSound);
    }

    // Stop background audio
    await audioService.fadeOutBackgroundSound(fadeOutSeconds: 2);
    await WakelockService.disable();

    // Record practice usage metadata
    await practiceRepo.recordPracticeUsage(practice.id);

    notifyListeners();
  }

  Future<MeditationSession> finalizeSession({
    SessionStatus? forcedStatus,
    String? mood,
    String? note,
  }) async {
    _ticker?.cancel();
    await audioService.stopAll();
    await WakelockService.disable();

    final status = forcedStatus ??
        (_elapsedSeconds >= (practice.durationSeconds * 0.9)
            ? SessionStatus.completed
            : (_elapsedSeconds >= 30
                ? SessionStatus.partial
                : SessionStatus.cancelled));

    final session = MeditationSession(
      id: sessionId,
      practiceId: practice.id,
      startedAt: _actualStartTime ?? _sessionStartTime ?? DateTime.now(),
      completedAt: DateTime.now(),
      plannedDurationSeconds: practice.durationSeconds,
      actualDurationSeconds: _elapsedSeconds,
      status: status,
      mood: mood,
      note: note,
      snapshot: snapshot,
    );

    // Save session in DB
    await sessionRepo.saveSession(session);

    // Update achievements
    final allSessions = await sessionRepo.getAllSessions();
    await achievementRepo.checkAndUnlockNewAchievements(allSessions);

    return session;
  }

  void toggleControls() {
    _controlsVisible = !_controlsVisible;
    notifyListeners();
  }

  void toggleDim() {
    _isDimmed = !_isDimmed;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WakelockService.disable();
    super.dispose();
  }
}
