class BodyScanConfig {
  final List<String> bodyParts;
  final bool announceWithBell;

  const BodyScanConfig({
    this.bodyParts = const [
      'Feet & Soles',
      'Lower Legs & Calves',
      'Knees',
      'Thighs & Pelvis',
      'Lower Back & Abdomen',
      'Chest & Heart Center',
      'Hands & Fingers',
      'Arms & Shoulders',
      'Neck & Throat',
      'Jaw & Face',
      'Crown of Head',
      'Whole Body Integration',
    ],
    this.announceWithBell = false,
  });

  Map<String, dynamic> toJson() => {
        'bodyParts': bodyParts,
        'announceWithBell': announceWithBell,
      };

  factory BodyScanConfig.fromJson(Map<String, dynamic> json) {
    return BodyScanConfig(
      bodyParts: (json['bodyParts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'Feet & Soles',
            'Lower Legs & Calves',
            'Knees',
            'Thighs & Pelvis',
            'Lower Back & Abdomen',
            'Chest & Heart Center',
            'Hands & Fingers',
            'Arms & Shoulders',
            'Neck & Throat',
            'Jaw & Face',
            'Crown of Head',
            'Whole Body Integration',
          ],
      announceWithBell: json['announceWithBell'] as bool? ?? false,
    );
  }

  BodyScanConfig copyWith({
    List<String>? bodyParts,
    bool? announceWithBell,
  }) {
    return BodyScanConfig(
      bodyParts: bodyParts ?? this.bodyParts,
      announceWithBell: announceWithBell ?? this.announceWithBell,
    );
  }
}
