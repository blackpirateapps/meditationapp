class BreathingConfig {
  final int inhaleSeconds;
  final int inhaleHoldSeconds;
  final int exhaleSeconds;
  final int exhaleHoldSeconds;
  final String presetName;

  const BreathingConfig({
    this.inhaleSeconds = 4,
    this.inhaleHoldSeconds = 4,
    this.exhaleSeconds = 4,
    this.exhaleHoldSeconds = 4,
    this.presetName = 'Box Breathing',
  });

  int get cycleDurationSeconds =>
      inhaleSeconds + inhaleHoldSeconds + exhaleSeconds + exhaleHoldSeconds;

  Map<String, dynamic> toJson() => {
        'inhaleSeconds': inhaleSeconds,
        'inhaleHoldSeconds': inhaleHoldSeconds,
        'exhaleSeconds': exhaleSeconds,
        'exhaleHoldSeconds': exhaleHoldSeconds,
        'presetName': presetName,
      };

  factory BreathingConfig.fromJson(Map<String, dynamic> json) {
    return BreathingConfig(
      inhaleSeconds: (json['inhaleSeconds'] as num?)?.toInt() ?? 4,
      inhaleHoldSeconds: (json['inhaleHoldSeconds'] as num?)?.toInt() ?? 0,
      exhaleSeconds: (json['exhaleSeconds'] as num?)?.toInt() ?? 4,
      exhaleHoldSeconds: (json['exhaleHoldSeconds'] as num?)?.toInt() ?? 0,
      presetName: json['presetName'] as String? ?? 'Custom',
    );
  }

  BreathingConfig copyWith({
    int? inhaleSeconds,
    int? inhaleHoldSeconds,
    int? exhaleSeconds,
    int? exhaleHoldSeconds,
    String? presetName,
  }) {
    return BreathingConfig(
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      inhaleHoldSeconds: inhaleHoldSeconds ?? this.inhaleHoldSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      exhaleHoldSeconds: exhaleHoldSeconds ?? this.exhaleHoldSeconds,
      presetName: presetName ?? this.presetName,
    );
  }

  static const box = BreathingConfig(
    inhaleSeconds: 4,
    inhaleHoldSeconds: 4,
    exhaleSeconds: 4,
    exhaleHoldSeconds: 4,
    presetName: 'Box Breathing (4-4-4-4)',
  );

  static const equal = BreathingConfig(
    inhaleSeconds: 4,
    inhaleHoldSeconds: 0,
    exhaleSeconds: 4,
    exhaleHoldSeconds: 0,
    presetName: 'Equal Breathing (4-4)',
  );

  static const fourSevenEight = BreathingConfig(
    inhaleSeconds: 4,
    inhaleHoldSeconds: 7,
    exhaleSeconds: 8,
    exhaleHoldSeconds: 0,
    presetName: 'Relaxing 4-7-8',
  );

  static const deepCalm = BreathingConfig(
    inhaleSeconds: 5,
    inhaleHoldSeconds: 2,
    exhaleSeconds: 7,
    exhaleHoldSeconds: 2,
    presetName: 'Deep Calm (5-2-7-2)',
  );

  static const presets = [box, equal, fourSevenEight, deepCalm];
}
