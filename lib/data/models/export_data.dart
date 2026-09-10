import 'dart:convert';
import 'practice.dart';
import 'meditation_session.dart';
import 'achievement.dart';
import 'app_settings.dart';

class ExportData {
  final int schemaVersion;
  final DateTime exportedAt;
  final List<Practice> practices;
  final List<MeditationSession> sessions;
  final List<Achievement> achievements;
  final AppSettings? settings;

  const ExportData({
    this.schemaVersion = 1,
    required this.exportedAt,
    required this.practices,
    required this.sessions,
    required this.achievements,
    this.settings,
  });

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'exportedAt': exportedAt.toIso8601String(),
        'practices': practices.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((e) => e.toJson()).toList(),
        'achievements': achievements.map((e) => e.toJson()).toList(),
        'settings': settings?.toJson(),
      };

  String toJsonString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  static ExportData fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ExportData.fromJson(map);
  }

  factory ExportData.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as num?;
    if (version == null || version.toInt() > 1) {
      throw FormatException('Unsupported backup format version: $version');
    }

    final exportedAt = DateTime.parse(json['exportedAt'] as String);

    final practicesRaw = json['practices'] as List<dynamic>? ?? [];
    final practices = practicesRaw
        .map((e) => Practice.fromJson(e as Map<String, dynamic>))
        .toList();

    final sessionsRaw = json['sessions'] as List<dynamic>? ?? [];
    final sessions = sessionsRaw
        .map((e) => MeditationSession.fromJson(e as Map<String, dynamic>))
        .toList();

    final achievementsRaw = json['achievements'] as List<dynamic>? ?? [];
    final achievements = achievementsRaw
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList();

    final settingsRaw = json['settings'] as Map<String, dynamic>?;
    final settings =
        settingsRaw != null ? AppSettings.fromJson(settingsRaw) : null;

    return ExportData(
      schemaVersion: version.toInt(),
      exportedAt: exportedAt,
      practices: practices,
      sessions: sessions,
      achievements: achievements,
      settings: settings,
    );
  }
}
