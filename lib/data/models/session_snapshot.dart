import 'breathing_config.dart';
import 'body_scan_config.dart';
import 'mantra_config.dart';
import 'walking_config.dart';
import 'meditation_type.dart';

class SessionSnapshot {
  final String practiceId;
  final String practiceName;
  final MeditationType meditationType;
  final int plannedDurationSeconds;
  final int preparationSeconds;
  final bool visualGuidance;
  final bool hapticGuidance;
  final bool intervalBellEnabled;
  final int intervalBellIntervalSeconds;
  final String intervalBellSound;
  final double intervalBellVolume;
  final String startSound;
  final bool startSoundEnabled;
  final String endingSound;
  final bool endingSoundEnabled;
  final String backgroundSound;
  final double backgroundSoundVolume;
  final int fadeInSeconds;
  final int fadeOutSeconds;
  final String screenBehavior;
  final BreathingConfig? breathingConfig;
  final BodyScanConfig? bodyScanConfig;
  final MantraConfig? mantraConfig;
  final WalkingConfig? walkingConfig;

  const SessionSnapshot({
    required this.practiceId,
    required this.practiceName,
    required this.meditationType,
    required this.plannedDurationSeconds,
    this.preparationSeconds = 10,
    this.visualGuidance = true,
    this.hapticGuidance = true,
    this.intervalBellEnabled = false,
    this.intervalBellIntervalSeconds = 300,
    this.intervalBellSound = 'singing_bowl',
    this.intervalBellVolume = 0.8,
    this.startSound = 'singing_bowl',
    this.startSoundEnabled = true,
    this.endingSound = 'tingsha',
    this.endingSoundEnabled = true,
    this.backgroundSound = 'none',
    this.backgroundSoundVolume = 0.5,
    this.fadeInSeconds = 3,
    this.fadeOutSeconds = 5,
    this.screenBehavior = 'keepAwake',
    this.breathingConfig,
    this.bodyScanConfig,
    this.mantraConfig,
    this.walkingConfig,
  });

  Map<String, dynamic> toJson() => {
        'practiceId': practiceId,
        'practiceName': practiceName,
        'meditationType': meditationType.name,
        'plannedDurationSeconds': plannedDurationSeconds,
        'preparationSeconds': preparationSeconds,
        'visualGuidance': visualGuidance,
        'hapticGuidance': hapticGuidance,
        'intervalBellEnabled': intervalBellEnabled,
        'intervalBellIntervalSeconds': intervalBellIntervalSeconds,
        'intervalBellSound': intervalBellSound,
        'intervalBellVolume': intervalBellVolume,
        'startSound': startSound,
        'startSoundEnabled': startSoundEnabled,
        'endingSound': endingSound,
        'endingSoundEnabled': endingSoundEnabled,
        'backgroundSound': backgroundSound,
        'backgroundSoundVolume': backgroundSoundVolume,
        'fadeInSeconds': fadeInSeconds,
        'fadeOutSeconds': fadeOutSeconds,
        'screenBehavior': screenBehavior,
        'breathingConfig': breathingConfig?.toJson(),
        'bodyScanConfig': bodyScanConfig?.toJson(),
        'mantraConfig': mantraConfig?.toJson(),
        'walkingConfig': walkingConfig?.toJson(),
      };

  factory SessionSnapshot.fromJson(Map<String, dynamic> json) {
    return SessionSnapshot(
      practiceId: json['practiceId'] as String? ?? '',
      practiceName: json['practiceName'] as String? ?? 'Meditation',
      meditationType: MeditationType.fromString(
          json['meditationType'] as String? ?? 'silentTimer'),
      plannedDurationSeconds:
          (json['plannedDurationSeconds'] as num?)?.toInt() ?? 600,
      preparationSeconds:
          (json['preparationSeconds'] as num?)?.toInt() ?? 10,
      visualGuidance: json['visualGuidance'] as bool? ?? true,
      hapticGuidance: json['hapticGuidance'] as bool? ?? true,
      intervalBellEnabled: json['intervalBellEnabled'] as bool? ?? false,
      intervalBellIntervalSeconds:
          (json['intervalBellIntervalSeconds'] as num?)?.toInt() ?? 300,
      intervalBellSound:
          json['intervalBellSound'] as String? ?? 'singing_bowl',
      intervalBellVolume:
          (json['intervalBellVolume'] as num?)?.toDouble() ?? 0.8,
      startSound: json['startSound'] as String? ?? 'singing_bowl',
      startSoundEnabled: json['startSoundEnabled'] as bool? ?? true,
      endingSound: json['endingSound'] as String? ?? 'tingsha',
      endingSoundEnabled: json['endingSoundEnabled'] as bool? ?? true,
      backgroundSound: json['backgroundSound'] as String? ?? 'none',
      backgroundSoundVolume:
          (json['backgroundSoundVolume'] as num?)?.toDouble() ?? 0.5,
      fadeInSeconds: (json['fadeInSeconds'] as num?)?.toInt() ?? 3,
      fadeOutSeconds: (json['fadeOutSeconds'] as num?)?.toInt() ?? 5,
      screenBehavior: json['screenBehavior'] as String? ?? 'keepAwake',
      breathingConfig: json['breathingConfig'] != null
          ? BreathingConfig.fromJson(
              json['breathingConfig'] as Map<String, dynamic>)
          : null,
      bodyScanConfig: json['bodyScanConfig'] != null
          ? BodyScanConfig.fromJson(
              json['bodyScanConfig'] as Map<String, dynamic>)
          : null,
      mantraConfig: json['mantraConfig'] != null
          ? MantraConfig.fromJson(
              json['mantraConfig'] as Map<String, dynamic>)
          : null,
      walkingConfig: json['walkingConfig'] != null
          ? WalkingConfig.fromJson(
              json['walkingConfig'] as Map<String, dynamic>)
          : null,
    );
  }
}
