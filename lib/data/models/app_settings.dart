import 'package:flutter/material.dart';

class AppSettings {
  final ThemeMode themeMode;
  final int defaultPreparationSeconds;
  final int defaultDurationSeconds;
  final String defaultStartSound;
  final bool defaultStartSoundEnabled;
  final String defaultEndingSound;
  final bool defaultEndingSoundEnabled;
  final bool defaultHaptics;
  final String defaultScreenBehavior;
  final String defaultBackgroundSound;
  final double defaultBackgroundVolume;
  final String defaultBellSound;
  final double defaultBellVolume;
  final int defaultFadeInSeconds;
  final int defaultFadeOutSeconds;
  final bool remindersEnabled;
  final String reminderSchedule; // 'off', 'daily', 'weekdays'
  final int reminderHour;
  final int reminderMinute;
  final bool keepScreenAwake;
  final bool dimDuringMeditation;
  final String sleepModeScreenBehavior;
  final bool confirmEndSession;
  final bool showRecentlyUsed;
  final bool showFavorites;
  final bool showPinned;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.defaultPreparationSeconds = 10,
    this.defaultDurationSeconds = 600,
    this.defaultStartSound = 'bell_singing_bowl',
    this.defaultStartSoundEnabled = true,
    this.defaultEndingSound = 'bell_tingsha',
    this.defaultEndingSoundEnabled = true,
    this.defaultHaptics = true,
    this.defaultScreenBehavior = 'keepAwake',
    this.defaultBackgroundSound = 'none',
    this.defaultBackgroundVolume = 0.5,
    this.defaultBellSound = 'bell_singing_bowl',
    this.defaultBellVolume = 0.8,
    this.defaultFadeInSeconds = 3,
    this.defaultFadeOutSeconds = 5,
    this.remindersEnabled = false,
    this.reminderSchedule = 'daily',
    this.reminderHour = 8,
    this.reminderMinute = 0,
    this.keepScreenAwake = true,
    this.dimDuringMeditation = false,
    this.sleepModeScreenBehavior = 'allowSleep',
    this.confirmEndSession = true,
    this.showRecentlyUsed = true,
    this.showFavorites = true,
    this.showPinned = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? defaultPreparationSeconds,
    int? defaultDurationSeconds,
    String? defaultStartSound,
    bool? defaultStartSoundEnabled,
    String? defaultEndingSound,
    bool? defaultEndingSoundEnabled,
    bool? defaultHaptics,
    String? defaultScreenBehavior,
    String? defaultBackgroundSound,
    double? defaultBackgroundVolume,
    String? defaultBellSound,
    double? defaultBellVolume,
    int? defaultFadeInSeconds,
    int? defaultFadeOutSeconds,
    bool? remindersEnabled,
    String? reminderSchedule,
    int? reminderHour,
    int? reminderMinute,
    bool? keepScreenAwake,
    bool? dimDuringMeditation,
    String? sleepModeScreenBehavior,
    bool? confirmEndSession,
    bool? showRecentlyUsed,
    bool? showFavorites,
    bool? showPinned,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      defaultPreparationSeconds:
          defaultPreparationSeconds ?? this.defaultPreparationSeconds,
      defaultDurationSeconds:
          defaultDurationSeconds ?? this.defaultDurationSeconds,
      defaultStartSound: defaultStartSound ?? this.defaultStartSound,
      defaultStartSoundEnabled:
          defaultStartSoundEnabled ?? this.defaultStartSoundEnabled,
      defaultEndingSound: defaultEndingSound ?? this.defaultEndingSound,
      defaultEndingSoundEnabled:
          defaultEndingSoundEnabled ?? this.defaultEndingSoundEnabled,
      defaultHaptics: defaultHaptics ?? this.defaultHaptics,
      defaultScreenBehavior:
          defaultScreenBehavior ?? this.defaultScreenBehavior,
      defaultBackgroundSound:
          defaultBackgroundSound ?? this.defaultBackgroundSound,
      defaultBackgroundVolume:
          defaultBackgroundVolume ?? this.defaultBackgroundVolume,
      defaultBellSound: defaultBellSound ?? this.defaultBellSound,
      defaultBellVolume: defaultBellVolume ?? this.defaultBellVolume,
      defaultFadeInSeconds: defaultFadeInSeconds ?? this.defaultFadeInSeconds,
      defaultFadeOutSeconds:
          defaultFadeOutSeconds ?? this.defaultFadeOutSeconds,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderSchedule: reminderSchedule ?? this.reminderSchedule,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      dimDuringMeditation: dimDuringMeditation ?? this.dimDuringMeditation,
      sleepModeScreenBehavior:
          sleepModeScreenBehavior ?? this.sleepModeScreenBehavior,
      confirmEndSession: confirmEndSession ?? this.confirmEndSession,
      showRecentlyUsed: showRecentlyUsed ?? this.showRecentlyUsed,
      showFavorites: showFavorites ?? this.showFavorites,
      showPinned: showPinned ?? this.showPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'defaultPreparationSeconds': defaultPreparationSeconds,
        'defaultDurationSeconds': defaultDurationSeconds,
        'defaultStartSound': defaultStartSound,
        'defaultStartSoundEnabled': defaultStartSoundEnabled,
        'defaultEndingSound': defaultEndingSound,
        'defaultEndingSoundEnabled': defaultEndingSoundEnabled,
        'defaultHaptics': defaultHaptics,
        'defaultScreenBehavior': defaultScreenBehavior,
        'defaultBackgroundSound': defaultBackgroundSound,
        'defaultBackgroundVolume': defaultBackgroundVolume,
        'defaultBellSound': defaultBellSound,
        'defaultBellVolume': defaultBellVolume,
        'defaultFadeInSeconds': defaultFadeInSeconds,
        'defaultFadeOutSeconds': defaultFadeOutSeconds,
        'remindersEnabled': remindersEnabled,
        'reminderSchedule': reminderSchedule,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'keepScreenAwake': keepScreenAwake,
        'dimDuringMeditation': dimDuringMeditation,
        'sleepModeScreenBehavior': sleepModeScreenBehavior,
        'confirmEndSession': confirmEndSession,
        'showRecentlyUsed': showRecentlyUsed,
        'showFavorites': showFavorites,
        'showPinned': showPinned,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    ThemeMode mode;
    switch (json['themeMode']) {
      case 'light':
        mode = ThemeMode.light;
        break;
      case 'dark':
        mode = ThemeMode.dark;
        break;
      default:
        mode = ThemeMode.system;
    }

    return AppSettings(
      themeMode: mode,
      defaultPreparationSeconds:
          (json['defaultPreparationSeconds'] as num?)?.toInt() ?? 10,
      defaultDurationSeconds:
          (json['defaultDurationSeconds'] as num?)?.toInt() ?? 600,
      defaultStartSound:
          json['defaultStartSound'] as String? ?? 'bell_singing_bowl',
      defaultStartSoundEnabled:
          json['defaultStartSoundEnabled'] as bool? ?? true,
      defaultEndingSound:
          json['defaultEndingSound'] as String? ?? 'bell_tingsha',
      defaultEndingSoundEnabled:
          json['defaultEndingSoundEnabled'] as bool? ?? true,
      defaultHaptics: json['defaultHaptics'] as bool? ?? true,
      defaultScreenBehavior:
          json['defaultScreenBehavior'] as String? ?? 'keepAwake',
      defaultBackgroundSound:
          json['defaultBackgroundSound'] as String? ?? 'none',
      defaultBackgroundVolume:
          (json['defaultBackgroundVolume'] as num?)?.toDouble() ?? 0.5,
      defaultBellSound:
          json['defaultBellSound'] as String? ?? 'bell_singing_bowl',
      defaultBellVolume:
          (json['defaultBellVolume'] as num?)?.toDouble() ?? 0.8,
      defaultFadeInSeconds:
          (json['defaultFadeInSeconds'] as num?)?.toInt() ?? 3,
      defaultFadeOutSeconds:
          (json['defaultFadeOutSeconds'] as num?)?.toInt() ?? 5,
      remindersEnabled: json['remindersEnabled'] as bool? ?? false,
      reminderSchedule: json['reminderSchedule'] as String? ?? 'daily',
      reminderHour: (json['reminderHour'] as num?)?.toInt() ?? 8,
      reminderMinute: (json['reminderMinute'] as num?)?.toInt() ?? 0,
      keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
      dimDuringMeditation: json['dimDuringMeditation'] as bool? ?? false,
      sleepModeScreenBehavior:
          json['sleepModeScreenBehavior'] as String? ?? 'allowSleep',
      confirmEndSession: json['confirmEndSession'] as bool? ?? true,
      showRecentlyUsed: json['showRecentlyUsed'] as bool? ?? true,
      showFavorites: json['showFavorites'] as bool? ?? true,
      showPinned: json['showPinned'] as bool? ?? true,
    );
  }
}
