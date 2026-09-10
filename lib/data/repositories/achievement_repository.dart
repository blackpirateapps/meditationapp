import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/achievement.dart';
import '../models/meditation_session.dart';
import '../models/meditation_type.dart';

class AchievementRepository {
  final AppDatabase _db;

  AchievementRepository(this._db);

  Stream<List<Achievement>> watchAllAchievements(
      Stream<List<MeditationSession>> sessionsStream) {
    return _db.select(_db.achievementsTable).watch().asyncMap((unlockedRows) async {
      final unlockedMap = {
        for (final r in unlockedRows) r.id: r.unlockedAt,
      };

      // We combine with latest sessions
      final allSessions = await (_db.select(_db.sessionsTable)).get();
      final sessions = allSessions.map((row) {
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
          'snapshot': {},
        });
      }).toList();

      return _computeAchievements(unlockedMap, sessions);
    });
  }

  Future<List<Achievement>> getAllAchievements(
      List<MeditationSession> sessions) async {
    final unlockedRows = await _db.select(_db.achievementsTable).get();
    final unlockedMap = {
      for (final r in unlockedRows) r.id: r.unlockedAt,
    };
    return _computeAchievements(unlockedMap, sessions);
  }

  List<Achievement> _computeAchievements(
    Map<String, DateTime> unlockedMap,
    List<MeditationSession> sessions,
  ) {
    final completedSessions =
        sessions.where((s) => s.status == SessionStatus.completed).toList();
    final totalCompleted = completedSessions.length;

    int totalSeconds = 0;
    final Set<String> uniqueDays = {};
    final Set<MeditationType> typesTried = {};
    int sleepCount = 0;
    bool hasEarlyBird = false;
    bool hasLongSit = false;

    for (final s in sessions) {
      if (s.actualDurationSeconds >= 10) {
        totalSeconds += s.actualDurationSeconds;
        uniqueDays.add(
            '${s.startedAt.year}-${s.startedAt.month}-${s.startedAt.day}');
        typesTried.add(s.snapshot.meditationType);

        if (s.startedAt.hour < 8) {
          hasEarlyBird = true;
        }
        if (s.actualDurationSeconds >= 1800) {
          hasLongSit = true;
        }
        if (s.snapshot.meditationType == MeditationType.sleep &&
            s.actualDurationSeconds >= 300) {
          sleepCount++;
        }
      }
    }

    return Achievement.definitions.map((def) {
      final unlockedAt = unlockedMap[def.id];
      double currentVal = 0.0;

      switch (def.id) {
        case 'first_breath':
          currentVal = totalCompleted.toDouble();
          break;
        case 'ten_sessions':
        case 'twenty_five_sessions':
        case 'fifty_sessions':
          currentVal = totalCompleted.toDouble();
          break;
        case 'one_hour':
        case 'five_hours':
        case 'ten_hours':
          currentVal = totalSeconds.toDouble();
          break;
        case 'seven_days':
        case 'thirty_days':
          currentVal = uniqueDays.length.toDouble();
          break;
        case 'early_bird':
          currentVal = hasEarlyBird ? 1.0 : 0.0;
          break;
        case 'long_sit':
          currentVal = hasLongSit ? 1800.0 : 0.0;
          break;
        case 'explorer':
          currentVal = typesTried.length.toDouble();
          break;
        case 'sleep_practice':
          currentVal = sleepCount.toDouble();
          break;
      }

      final progress =
          (currentVal / def.threshold).clamp(0.0, 1.0).toDouble();

      return def.copyWith(
        progress: progress,
        unlockedAt: unlockedAt,
      );
    }).toList();
  }

  /// Evaluates whether any achievement was newly unlocked by a completed session
  Future<List<Achievement>> checkAndUnlockNewAchievements(
      List<MeditationSession> allSessions) async {
    final unlockedRows = await _db.select(_db.achievementsTable).get();
    final unlockedMap = {
      for (final r in unlockedRows) r.id: r.unlockedAt,
    };

    final evaluated = _computeAchievements(unlockedMap, allSessions);
    final newlyUnlocked = <Achievement>[];
    final now = DateTime.now();

    for (final ach in evaluated) {
      if (ach.unlockedAt == null && ach.progress >= 1.0) {
        await _db.into(_db.achievementsTable).insertOnConflictUpdate(
              AchievementsTableCompanion(
                id: Value(ach.id),
                unlockedAt: Value(now),
              ),
            );
        newlyUnlocked.add(ach.copyWith(unlockedAt: now));
      }
    }

    return newlyUnlocked;
  }
}
