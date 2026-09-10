class WalkingConfig {
  final int stepPacingPromptSeconds;
  final bool announcePhases;
  final List<String> walkingPhases;

  const WalkingConfig({
    this.stepPacingPromptSeconds = 60,
    this.announcePhases = true,
    this.walkingPhases = const [
      'Grounded footsteps: notice contact with the earth',
      'Rhythm of breath in motion',
      'Awareness of sounds and breeze',
      'Open walking: effortless, unified presence',
    ],
  });

  Map<String, dynamic> toJson() => {
        'stepPacingPromptSeconds': stepPacingPromptSeconds,
        'announcePhases': announcePhases,
        'walkingPhases': walkingPhases,
      };

  factory WalkingConfig.fromJson(Map<String, dynamic> json) {
    return WalkingConfig(
      stepPacingPromptSeconds:
          (json['stepPacingPromptSeconds'] as num?)?.toInt() ?? 60,
      announcePhases: json['announcePhases'] as bool? ?? true,
      walkingPhases: (json['walkingPhases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'Grounded footsteps: notice contact with the earth',
            'Rhythm of breath in motion',
            'Awareness of sounds and breeze',
            'Open walking: effortless, unified presence',
          ],
    );
  }

  WalkingConfig copyWith({
    int? stepPacingPromptSeconds,
    bool? announcePhases,
    List<String>? walkingPhases,
  }) {
    return WalkingConfig(
      stepPacingPromptSeconds:
          stepPacingPromptSeconds ?? this.stepPacingPromptSeconds,
      announcePhases: announcePhases ?? this.announcePhases,
      walkingPhases: walkingPhases ?? this.walkingPhases,
    );
  }
}
