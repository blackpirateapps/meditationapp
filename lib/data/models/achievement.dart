class Achievement {
  final String id;
  final String title;
  final String description;
  final String category; // 'milestone', 'time', 'consistency', 'exploration'
  final int threshold;
  final double progress; // 0.0 to 1.0
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.threshold,
    this.progress = 0.0,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? threshold,
    double? progress,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      threshold: threshold ?? this.threshold,
      progress: progress ?? this.progress,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'threshold': threshold,
        'progress': progress,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      threshold: (json['threshold'] as num).toInt(),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  // Pre-defined achievement definitions according to Section 29
  static const List<Achievement> definitions = [
    Achievement(
      id: 'first_breath',
      title: 'First Breath',
      description: 'Completed your first meditation session.',
      category: 'milestone',
      threshold: 1,
    ),
    Achievement(
      id: 'ten_sessions',
      title: 'Ten Sessions',
      description: 'Completed 10 meditation sessions.',
      category: 'milestone',
      threshold: 10,
    ),
    Achievement(
      id: 'twenty_five_sessions',
      title: 'Twenty-Five Sessions',
      description: 'Completed 25 meditation sessions.',
      category: 'milestone',
      threshold: 25,
    ),
    Achievement(
      id: 'fifty_sessions',
      title: 'Fifty Sessions',
      description: 'Completed 50 meditation sessions.',
      category: 'milestone',
      threshold: 50,
    ),
    Achievement(
      id: 'one_hour',
      title: 'One Hour',
      description: 'Accumulated one hour in meditation.',
      category: 'time',
      threshold: 3600, // 3600 seconds
    ),
    Achievement(
      id: 'five_hours',
      title: 'Five Hours',
      description: 'Accumulated five hours in meditation.',
      category: 'time',
      threshold: 18000, // 5 hours in seconds
    ),
    Achievement(
      id: 'ten_hours',
      title: 'Ten Hours',
      description: 'Accumulated ten hours in meditation.',
      category: 'time',
      threshold: 36000, // 10 hours in seconds
    ),
    Achievement(
      id: 'seven_days',
      title: 'Seven Days',
      description: 'Meditated on seven different days.',
      category: 'consistency',
      threshold: 7,
    ),
    Achievement(
      id: 'thirty_days',
      title: 'Thirty Days',
      description: 'Meditated on thirty different days.',
      category: 'consistency',
      threshold: 30,
    ),
    Achievement(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Completed an early-morning session before 8:00 AM.',
      category: 'exploration',
      threshold: 1,
    ),
    Achievement(
      id: 'long_sit',
      title: 'Long Sit',
      description: 'Completed a single session of at least 30 minutes.',
      category: 'exploration',
      threshold: 1800,
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorer',
      description: 'Practiced at least five different meditation types.',
      category: 'exploration',
      threshold: 5,
    ),
    Achievement(
      id: 'sleep_practice',
      title: 'Sleep Practice',
      description: 'Completed ten sleep meditation sessions.',
      category: 'exploration',
      threshold: 10,
    ),
  ];
}
