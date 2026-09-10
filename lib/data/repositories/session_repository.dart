import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/meditation_session.dart';
import '../models/meditation_type.dart';

class SessionStats {
  final int totalSeconds;
  final int totalSessions;
  final int averageSeconds;
  final int daysMeditated;
  final int currentStreak;
  final int longestStreak;
  final Map<MeditationType, int> typeSeconds;
  final Map<DateTime, int> dailyMinutes;

  const SessionStats({
    this.totalSeconds = 0,
    this.totalSessions = 0,
    this.averageSeconds = 0,
    this.daysMeditated = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.typeSeconds = const {},
    this.dailyMinutes = const {},
  });
}

class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  MeditationSession _fromRow(SessionsTableData row) {
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
  }

  SessionsTableCompanion _toCompanion(MeditationSession s) {
    return SessionsTableCompanion(
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
  }

  Stream<List<MeditationSession>> watchAllSessions() {
    return (_db.select(_db.sessionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch()
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<List<MeditationSession>> getAllSessions() async {
    final rows = await (_db.select(_db.sessionsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<MeditationSession?> getSessionById(String id) async {
    final query = _db.select(_db.sessionsTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  Future<void> saveSession(MeditationSession session) async {
    final companion = _toCompanion(session);
    await _db.into(_db.sessionsTable).insertOnConflictUpdate(companion);
  }

  Future<bool> deleteSession(String id) async {
    final count = await (_db.delete(_db.sessionsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    return count > 0;
  }

  Future<void> clearAllSessions() async {
    await _db.delete(_db.sessionsTable).go();
  }

  /// Calculates consistent statistics across the entire application (Section 55)
  SessionStats calculateStats(List<MeditationSession> allSessions,
      {String period = 'allTime', DateTime? referenceDate}) {
    final ref = referenceDate ?? DateTime.now();

    // 1. Filter sessions by period if requested
    final filtered = allSessions.where((s) {
      if (s.status == SessionStatus.cancelled && s.actualDurationSeconds < 30) {
        return false;
      }
      if (period == 'allTime') return true;

      final diff = ref.difference(s.startedAt);
      if (period == 'week') {
        return diff.inDays < 7 && s.startedAt.isBefore(ref.add(const Duration(days: 1)));
      } else if (period == 'month') {
        return diff.inDays < 30 && s.startedAt.isBefore(ref.add(const Duration(days: 1)));
      } else if (period == 'year') {
        return diff.inDays < 365 && s.startedAt.isBefore(ref.add(const Duration(days: 1)));
      }
      return true;
    }).toList();

    int totalSec = 0;
    int validSessionsCount = 0;
    final Set<String> uniqueDays = {};
    final Map<MeditationType, int> typeSecMap = {};
    final Map<DateTime, int> dailyMinMap = {};

    for (final s in filtered) {
      // Meaningful sessions count towards time
      if (s.actualDurationSeconds >= 10) {
        totalSec += s.actualDurationSeconds;
        validSessionsCount++;

        final dayKey =
            '${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}-${s.startedAt.day.toString().padLeft(2, '0')}';
        uniqueDays.add(dayKey);

        final normDate = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
        dailyMinMap[normDate] = (dailyMinMap[normDate] ?? 0) + (s.actualDurationSeconds ~/ 60);

        final t = s.snapshot.meditationType;
        typeSecMap[t] = (typeSecMap[t] ?? 0) + s.actualDurationSeconds;
      }
    }

    final avgSec =
        validSessionsCount > 0 ? (totalSec ~/ validSessionsCount) : 0;

    // Streaks calculation based on all sessions ever
    final (currentStreak, longestStreak) = _calculateStreaks(allSessions, ref);

    return SessionStats(
      totalSeconds: totalSec,
      totalSessions: validSessionsCount,
      averageSeconds: avgSec,
      daysMeditated: uniqueDays.length,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      typeSeconds: typeSecMap,
      dailyMinutes: dailyMinMap,
    );
  }

  (int, int) _calculateStreaks(List<MeditationSession> sessions, DateTime ref) {
    if (sessions.isEmpty) return (0, 0);

    // Get all unique active days sorted ascending
    final Set<DateTime> daysSet = {};
    for (final s in sessions) {
      if (s.actualDurationSeconds >= 60) {
        daysSet.add(DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day));
      }
    }

    if (daysSet.isEmpty) return (0, 0);

    final sortedDays = daysSet.toList()..sort((a, b) => a.compareTo(b));

    int maxStreak = 0;
    int tempStreak = 0;
    DateTime? prev;

    for (final d in sortedDays) {
      if (prev == null) {
        tempStreak = 1;
      } else {
        final diff = d.difference(prev).inDays;
        if (diff == 1) {
          tempStreak++;
        } else if (diff > 1) {
          tempStreak = 1;
        }
      }
      if (tempStreak > maxStreak) {
        maxStreak = tempStreak;
      }
      prev = d;
    }

    // Current streak
    final today = DateTime(ref.year, ref.month, ref.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int curStreak = 0;
    DateTime checkDay = daysSet.contains(today) ? today : yesterday;

    while (daysSet.contains(checkDay)) {
      curStreak++;
      checkDay = checkDay.subtract(const Duration(days: 1));
    }

    return (curStreak, maxStreak);
  }
}
