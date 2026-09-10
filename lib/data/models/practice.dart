import 'dart:convert';
import 'meditation_type.dart';
import 'breathing_config.dart';
import 'body_scan_config.dart';
import 'mantra_config.dart';
import 'walking_config.dart';
import 'session_snapshot.dart';

class Practice {
  final String id;
  final String name;
  final String description;
  final MeditationType type;
  final int durationSeconds;
  final int preparationSeconds;
  final String guidanceMode; // 'none', 'subtle', 'visual'
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
  final String screenBehavior; // 'system', 'keepAwake', 'allowSleep'
  final BreathingConfig? breathingConfig;
  final BodyScanConfig? bodyScanConfig;
  final MantraConfig? mantraConfig;
  final WalkingConfig? walkingConfig;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn;
  final bool isFavorite;
  final bool isPinned;
  final int useCount;
  final DateTime? lastUsedAt;

  const Practice({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.durationSeconds,
    this.preparationSeconds = 10,
    this.guidanceMode = 'visual',
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
    required this.createdAt,
    required this.updatedAt,
    this.isBuiltIn = false,
    this.isFavorite = false,
    this.isPinned = false,
    this.useCount = 0,
    this.lastUsedAt,
  });

  SessionSnapshot toSnapshot() {
    return SessionSnapshot(
      practiceId: id,
      practiceName: name,
      meditationType: type,
      plannedDurationSeconds: durationSeconds,
      preparationSeconds: preparationSeconds,
      visualGuidance: visualGuidance,
      hapticGuidance: hapticGuidance,
      intervalBellEnabled: intervalBellEnabled,
      intervalBellIntervalSeconds: intervalBellIntervalSeconds,
      intervalBellSound: intervalBellSound,
      intervalBellVolume: intervalBellVolume,
      startSound: startSound,
      startSoundEnabled: startSoundEnabled,
      endingSound: endingSound,
      endingSoundEnabled: endingSoundEnabled,
      backgroundSound: backgroundSound,
      backgroundSoundVolume: backgroundSoundVolume,
      fadeInSeconds: fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds,
      screenBehavior: screenBehavior,
      breathingConfig: breathingConfig,
      bodyScanConfig: bodyScanConfig,
      mantraConfig: mantraConfig,
      walkingConfig: walkingConfig,
    );
  }

  Practice copyWith({
    String? id,
    String? name,
    String? description,
    MeditationType? type,
    int? durationSeconds,
    int? preparationSeconds,
    String? guidanceMode,
    bool? visualGuidance,
    bool? hapticGuidance,
    bool? intervalBellEnabled,
    int? intervalBellIntervalSeconds,
    String? intervalBellSound,
    double? intervalBellVolume,
    String? startSound,
    bool? startSoundEnabled,
    String? endingSound,
    bool? endingSoundEnabled,
    String? backgroundSound,
    double? backgroundSoundVolume,
    int? fadeInSeconds,
    int? fadeOutSeconds,
    String? screenBehavior,
    BreathingConfig? breathingConfig,
    BodyScanConfig? bodyScanConfig,
    MantraConfig? mantraConfig,
    WalkingConfig? walkingConfig,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
    bool? isFavorite,
    bool? isPinned,
    int? useCount,
    DateTime? lastUsedAt,
  }) {
    return Practice(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      preparationSeconds: preparationSeconds ?? this.preparationSeconds,
      guidanceMode: guidanceMode ?? this.guidanceMode,
      visualGuidance: visualGuidance ?? this.visualGuidance,
      hapticGuidance: hapticGuidance ?? this.hapticGuidance,
      intervalBellEnabled: intervalBellEnabled ?? this.intervalBellEnabled,
      intervalBellIntervalSeconds:
          intervalBellIntervalSeconds ?? this.intervalBellIntervalSeconds,
      intervalBellSound: intervalBellSound ?? this.intervalBellSound,
      intervalBellVolume: intervalBellVolume ?? this.intervalBellVolume,
      startSound: startSound ?? this.startSound,
      startSoundEnabled: startSoundEnabled ?? this.startSoundEnabled,
      endingSound: endingSound ?? this.endingSound,
      endingSoundEnabled: endingSoundEnabled ?? this.endingSoundEnabled,
      backgroundSound: backgroundSound ?? this.backgroundSound,
      backgroundSoundVolume:
          backgroundSoundVolume ?? this.backgroundSoundVolume,
      fadeInSeconds: fadeInSeconds ?? this.fadeInSeconds,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
      screenBehavior: screenBehavior ?? this.screenBehavior,
      breathingConfig: breathingConfig ?? this.breathingConfig,
      bodyScanConfig: bodyScanConfig ?? this.bodyScanConfig,
      mantraConfig: mantraConfig ?? this.mantraConfig,
      walkingConfig: walkingConfig ?? this.walkingConfig,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      useCount: useCount ?? this.useCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toConfigJson() {
    return {
      'guidanceMode': guidanceMode,
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
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'durationSeconds': durationSeconds,
      'preparationSeconds': preparationSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isBuiltIn': isBuiltIn,
      'isFavorite': isFavorite,
      'isPinned': isPinned,
      'useCount': useCount,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'configuration': toConfigJson(),
    };
  }

  factory Practice.fromJson(Map<String, dynamic> json) {
    final config = json['configuration'] is Map<String, dynamic>
        ? json['configuration'] as Map<String, dynamic>
        : (json['configuration'] is String
            ? jsonDecode(json['configuration'] as String)
                as Map<String, dynamic>
            : <String, dynamic>{});

    return Practice(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: MeditationType.fromString(json['type'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      preparationSeconds: (json['preparationSeconds'] as num?)?.toInt() ?? 10,
      guidanceMode: config['guidanceMode'] as String? ?? 'visual',
      visualGuidance: config['visualGuidance'] as bool? ?? true,
      hapticGuidance: config['hapticGuidance'] as bool? ?? true,
      intervalBellEnabled: config['intervalBellEnabled'] as bool? ?? false,
      intervalBellIntervalSeconds:
          (config['intervalBellIntervalSeconds'] as num?)?.toInt() ?? 300,
      intervalBellSound:
          config['intervalBellSound'] as String? ?? 'singing_bowl',
      intervalBellVolume:
          (config['intervalBellVolume'] as num?)?.toDouble() ?? 0.8,
      startSound: config['startSound'] as String? ?? 'singing_bowl',
      startSoundEnabled: config['startSoundEnabled'] as bool? ?? true,
      endingSound: config['endingSound'] as String? ?? 'tingsha',
      endingSoundEnabled: config['endingSoundEnabled'] as bool? ?? true,
      backgroundSound: config['backgroundSound'] as String? ?? 'none',
      backgroundSoundVolume:
          (config['backgroundSoundVolume'] as num?)?.toDouble() ?? 0.5,
      fadeInSeconds: (config['fadeInSeconds'] as num?)?.toInt() ?? 3,
      fadeOutSeconds: (config['fadeOutSeconds'] as num?)?.toInt() ?? 5,
      screenBehavior: config['screenBehavior'] as String? ?? 'keepAwake',
      breathingConfig: config['breathingConfig'] != null
          ? BreathingConfig.fromJson(
              config['breathingConfig'] as Map<String, dynamic>)
          : null,
      bodyScanConfig: config['bodyScanConfig'] != null
          ? BodyScanConfig.fromJson(
              config['bodyScanConfig'] as Map<String, dynamic>)
          : null,
      mantraConfig: config['mantraConfig'] != null
          ? MantraConfig.fromJson(
              config['mantraConfig'] as Map<String, dynamic>)
          : null,
      walkingConfig: config['walkingConfig'] != null
          ? WalkingConfig.fromJson(
              config['walkingConfig'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      useCount: (json['useCount'] as num?)?.toInt() ?? 0,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
    );
  }

  // Built-in presets specified in Section 51
  static List<Practice> get builtIns {
    final now = DateTime(2026, 1, 1);
    return [
      Practice(
        id: 'builtin_morning_breathing',
        name: 'Morning Breathing',
        description: 'Awaken body and mind with balanced box breathing.',
        type: MeditationType.breathing,
        durationSeconds: 600, // 10 min
        preparationSeconds: 10,
        startSound: 'bell_chime',
        endingSound: 'bell_tingsha',
        backgroundSound: 'ambient_soft',
        backgroundSoundVolume: 0.35,
        breathingConfig: BreathingConfig.box,
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_quiet_focus',
        name: 'Quiet Focus',
        description: 'Center your awareness on a single focal anchor.',
        type: MeditationType.focus,
        durationSeconds: 600, // 10 min
        preparationSeconds: 10,
        startSound: 'bell_singing_bowl',
        endingSound: 'bell_tingsha',
        backgroundSound: 'none',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_open_awareness',
        name: 'Open Awareness',
        description: 'Spacious resting in whatever arises, free from clinging.',
        type: MeditationType.openAwareness,
        durationSeconds: 1200, // 20 min
        preparationSeconds: 15,
        intervalBellEnabled: true,
        intervalBellIntervalSeconds: 300,
        intervalBellSound: 'bell_chime',
        startSound: 'bell_singing_bowl',
        endingSound: 'bell_gong',
        backgroundSound: 'none',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_body_scan',
        name: 'Body Scan',
        description: 'Gradual somatic release through guided sequential attention.',
        type: MeditationType.bodyScan,
        durationSeconds: 900, // 15 min
        preparationSeconds: 10,
        startSound: 'bell_singing_bowl',
        endingSound: 'bell_tingsha',
        backgroundSound: 'nature_ocean',
        backgroundSoundVolume: 0.3,
        bodyScanConfig: const BodyScanConfig(),
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_evening_reset',
        name: 'Evening Reset',
        description: 'Unwind the day’s tensions in quiet reflection.',
        type: MeditationType.openAwareness,
        durationSeconds: 600, // 10 min
        preparationSeconds: 10,
        startSound: 'bell_singing_bowl',
        endingSound: 'bell_tingsha',
        backgroundSound: 'nature_fireplace',
        backgroundSoundVolume: 0.35,
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_sleep',
        name: 'Sleep',
        description: 'Deep somatic calming with ambient rain and gentle fade.',
        type: MeditationType.sleep,
        durationSeconds: 1800, // 30 min
        preparationSeconds: 5,
        startSoundEnabled: false,
        endingSoundEnabled: false,
        backgroundSound: 'nature_rain',
        backgroundSoundVolume: 0.6,
        fadeOutSeconds: 30,
        screenBehavior: 'allowSleep',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_silent_meditation',
        name: 'Silent Meditation',
        description: 'Pure, unadorned timer with Tibetan singing bowl bells.',
        type: MeditationType.silentTimer,
        durationSeconds: 1200, // 20 min
        preparationSeconds: 10,
        startSound: 'bell_singing_bowl',
        endingSound: 'bell_gong',
        backgroundSound: 'none',
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
      Practice(
        id: 'builtin_walking_meditation',
        name: 'Walking Meditation',
        description: 'Mindful paced movement connecting stride and breath.',
        type: MeditationType.walking,
        durationSeconds: 900, // 15 min
        preparationSeconds: 10,
        startSound: 'bell_tingsha',
        endingSound: 'bell_tingsha',
        intervalBellEnabled: true,
        intervalBellIntervalSeconds: 300,
        intervalBellSound: 'bell_chime',
        backgroundSound: 'nature_forest',
        backgroundSoundVolume: 0.3,
        walkingConfig: const WalkingConfig(),
        createdAt: now,
        updatedAt: now,
        isBuiltIn: true,
      ),
    ];
  }
}
