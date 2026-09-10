class MantraConfig {
  final String mantraText;
  final int intervalSeconds; // Interval to gently pulse or remind
  final bool hapticOnPulse;

  const MantraConfig({
    this.mantraText = 'Peace begins with me',
    this.intervalSeconds = 15,
    this.hapticOnPulse = true,
  });

  Map<String, dynamic> toJson() => {
        'mantraText': mantraText,
        'intervalSeconds': intervalSeconds,
        'hapticOnPulse': hapticOnPulse,
      };

  factory MantraConfig.fromJson(Map<String, dynamic> json) {
    return MantraConfig(
      mantraText: json['mantraText'] as String? ?? 'Peace begins with me',
      intervalSeconds: (json['intervalSeconds'] as num?)?.toInt() ?? 15,
      hapticOnPulse: json['hapticOnPulse'] as bool? ?? true,
    );
  }

  MantraConfig copyWith({
    String? mantraText,
    int? intervalSeconds,
    bool? hapticOnPulse,
  }) {
    return MantraConfig(
      mantraText: mantraText ?? this.mantraText,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      hapticOnPulse: hapticOnPulse ?? this.hapticOnPulse,
    );
  }
}
