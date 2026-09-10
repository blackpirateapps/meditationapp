import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/app_settings.dart';
import '../models/export_data.dart';
import '../models/practice.dart';
import '../models/meditation_session.dart';
import '../models/achievement.dart';

class SettingsRepository {
  final AppDatabase _db;
  static const _settingsKey = 'app_settings';

  SettingsRepository(this._db);

  Stream<AppSettings> watchSettings() {
    final query = _db.select(_db.settingsTable)
      ..where((tbl) => tbl.key.equals(_settingsKey));
    return query.watchSingleOrNull().map((row) {
      if (row == null) return const AppSettings();
      try {
        final map = jsonDecode(row.value) as Map<String, dynamic>;
        return AppSettings.fromJson(map);
      } catch (_) {
        return const AppSettings();
      }
    });
  }

  Future<AppSettings> getSettings() async {
    final query = _db.select(_db.settingsTable)
      ..where((tbl) => tbl.key.equals(_settingsKey));
    final row = await query.getSingleOrNull();
    if (row == null) return const AppSettings();
    try {
      final map = jsonDecode(row.value) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final val = jsonEncode(settings.toJson());
    await _db.into(_db.settingsTable).insertOnConflictUpdate(
          SettingsTableCompanion(
            key: const Value(_settingsKey),
            value: Value(val),
          ),
        );
  }

  Future<ExportData> exportAllData() async {
    final pRows = await _db.select(_db.practicesTable).get();
    final practices = pRows.map((row) {
      return Practice.fromJson({
        'id': row.id,
        'name': row.name,
        'description': row.description,
        'type': row.type,
        'durationSeconds': row.durationSeconds,
        'preparationSeconds': row.preparationSeconds,
        'createdAt': row.createdAt.toIso8601String(),
        'updatedAt': row.updatedAt.toIso8601String(),
        'isBuiltIn': row.isBuiltIn,
        'isFavorite': row.isFavorite,
        'isPinned': row.isPinned,
        'useCount': row.useCount,
        'lastUsedAt': row.lastUsedAt?.toIso8601String(),
        'configuration': jsonDecode(row.configurationJson),
      });
    }).toList();

    final sRows = await _db.select(_db.sessionsTable).get();
    final sessions = sRows.map((row) {
      return MeditationSession.fromJson({
        'id': row.id,
        'practiceId': row.practiceId,
        'startedAt': row.startedAt.toIso8601String(),
        'completedAt': row.completedAt.toIso8601String(),
        'plannedDurationSeconds': row.plannedDurationSeconds,
        'actualDurationSeconds': row.actualDurationSeconds,
        'status': row.status,
        'mood': row.mood,
        'note': row.note,
        'snapshot': jsonDecode(row.snapshotJson),
      });
    }).toList();

    final aRows = await _db.select(_db.achievementsTable).get();
    final achievements = aRows.map((row) {
      final def = Achievement.definitions.firstWhere(
        (d) => d.id == row.id,
        orElse: () => Achievement(
          id: row.id,
          title: row.id,
          description: '',
          category: 'milestone',
          threshold: 1,
        ),
      );
      return def.copyWith(unlockedAt: row.unlockedAt);
    }).toList();

    final settings = await getSettings();

    return ExportData(
      schemaVersion: 1,
      exportedAt: DateTime.now(),
      practices: practices,
      sessions: sessions,
      achievements: achievements,
      settings: settings,
    );
  }

  Future<void> importData(String jsonString, {bool overwrite = false}) async {
    final data = ExportData.fromJsonString(jsonString);

    if (overwrite) {
      await _db.delete(_db.sessionsTable).go();
      await _db.delete(_db.achievementsTable).go();
      // Delete non-built-in practices
      await (_db.delete(_db.practicesTable)
            ..where((tbl) => tbl.isBuiltIn.equals(false)))
          .go();
    }

    // Import practices
    for (final p in data.practices) {
      final companion = PracticesTableCompanion(
        id: Value(p.id),
        name: Value(p.name),
        description: Value(p.description),
        type: Value(p.type.name),
        durationSeconds: Value(p.durationSeconds),
        preparationSeconds: Value(p.preparationSeconds),
        createdAt: Value(p.createdAt),
        updatedAt: Value(p.updatedAt),
        isBuiltIn: Value(p.isBuiltIn),
        isFavorite: Value(p.isFavorite),
        isPinned: Value(p.isPinned),
        useCount: Value(p.useCount),
        lastUsedAt: Value(p.lastUsedAt),
        configurationJson: Value(jsonEncode(p.toConfigJson())),
      );
      await _db.into(_db.practicesTable).insertOnConflictUpdate(companion);
    }

    // Import sessions
    for (final s in data.sessions) {
      final companion = SessionsTableCompanion(
        id: Value(s.id),
        practiceId: Value(s.practiceId),
        startedAt: Value(s.startedAt),
        completedAt: Value(s.completedAt),
        plannedDurationSeconds: Value(s.plannedDurationSeconds),
        actualDurationSeconds: Value(s.actualDurationSeconds),
        status: Value(s.status.name),
        mood: Value(s.mood),
        note: Value(s.note),
        snapshotJson: Value(jsonEncode(s.snapshot.toJson())),
      );
      await _db.into(_db.sessionsTable).insertOnConflictUpdate(companion);
    }

    // Import achievements
    for (final a in data.achievements) {
      if (a.unlockedAt != null) {
        await _db.into(_db.achievementsTable).insertOnConflictUpdate(
              AchievementsTableCompanion(
                id: Value(a.id),
                unlockedAt: Value(a.unlockedAt!),
              ),
            );
      }
    }

    // Import settings if present
    if (data.settings != null) {
      await saveSettings(data.settings!);
    }
  }

  Future<void> deleteAllMeditationData() async {
    // Delete all sessions
    await _db.delete(_db.sessionsTable).go();
    // Delete all achievements
    await _db.delete(_db.achievementsTable).go();
    // Delete custom practices, keep built-ins
    await (_db.delete(_db.practicesTable)
          ..where((tbl) => tbl.isBuiltIn.equals(false)))
        .go();
    // Reset built-ins use counts
    final pRows = await _db.select(_db.practicesTable).get();
    for (final r in pRows) {
      await (_db.update(_db.practicesTable)..where((tbl) => tbl.id.equals(r.id)))
          .write(
        const PracticesTableCompanion(
          useCount: Value(0),
          lastUsedAt: Value(null),
          isFavorite: Value(false),
          isPinned: Value(false),
        ),
      );
    }
  }

  Future<void> resetSettings() async {
    await saveSettings(const AppSettings());
  }

  Future<void> resetEntireApp() async {
    await _db.delete(_db.sessionsTable).go();
    await _db.delete(_db.achievementsTable).go();
    await _db.delete(_db.practicesTable).go();
    await _db.delete(_db.settingsTable).go();

    // Re-seed built-ins
    for (final p in Practice.builtIns) {
      final companion = PracticesTableCompanion(
        id: Value(p.id),
        name: Value(p.name),
        description: Value(p.description),
        type: Value(p.type.name),
        durationSeconds: Value(p.durationSeconds),
        preparationSeconds: Value(p.preparationSeconds),
        createdAt: Value(p.createdAt),
        updatedAt: Value(p.updatedAt),
        isBuiltIn: Value(p.isBuiltIn),
        isFavorite: Value(p.isFavorite),
        isPinned: Value(p.isPinned),
        useCount: Value(p.useCount),
        lastUsedAt: Value(p.lastUsedAt),
        configurationJson: Value(jsonEncode(p.toConfigJson())),
      );
      await _db.into(_db.practicesTable).insert(companion);
    }
    await saveSettings(const AppSettings());
  }
}
