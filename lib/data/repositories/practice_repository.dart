import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/practice.dart';
import '../models/meditation_type.dart';

class PracticeRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  PracticeRepository(this._db);

  Future<void> initDefaults() async {
    final count = await _db.practicesTable.count().getSingle();
    if (count == 0) {
      for (final practice in Practice.builtIns) {
        await savePractice(practice);
      }
    }
  }

  Practice _fromRow(PracticesTableData row) {
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
  }

  PracticesTableCompanion _toCompanion(Practice p) {
    return PracticesTableCompanion(
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
  }

  Stream<List<Practice>> watchAllPractices() {
    return _db.select(_db.practicesTable).watch().map(
          (rows) => rows.map(_fromRow).toList(),
        );
  }

  Future<List<Practice>> getAllPractices() async {
    final rows = await _db.select(_db.practicesTable).get();
    return rows.map(_fromRow).toList();
  }

  Future<Practice?> getPracticeById(String id) async {
    final query = _db.select(_db.practicesTable)
      ..where((tbl) => tbl.id.equals(id));
    final row = await query.getSingleOrNull();
    return row != null ? _fromRow(row) : null;
  }

  Future<void> savePractice(Practice practice) async {
    final companion = _toCompanion(practice);
    await _db.into(_db.practicesTable).insertOnConflictUpdate(companion);
  }

  Future<bool> deletePractice(String id) async {
    final practice = await getPracticeById(id);
    if (practice == null || practice.isBuiltIn) {
      return false; // Prevent deleting built-ins
    }
    final count = await (_db.delete(_db.practicesTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
    return count > 0;
  }

  Future<Practice> duplicatePractice(String id) async {
    final original = await getPracticeById(id);
    if (original == null) {
      throw Exception('Practice not found');
    }
    final now = DateTime.now();
    final duplicate = original.copyWith(
      id: _uuid.v4(),
      name: '${original.name} (Copy)',
      isBuiltIn: false,
      isFavorite: false,
      isPinned: false,
      useCount: 0,
      lastUsedAt: null,
      createdAt: now,
      updatedAt: now,
    );
    await savePractice(duplicate);
    return duplicate;
  }

  Future<void> toggleFavorite(String id) async {
    final practice = await getPracticeById(id);
    if (practice != null) {
      await savePractice(practice.copyWith(
        isFavorite: !practice.isFavorite,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> togglePin(String id) async {
    final practice = await getPracticeById(id);
    if (practice != null) {
      await savePractice(practice.copyWith(
        isPinned: !practice.isPinned,
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> recordPracticeUsage(String id) async {
    final practice = await getPracticeById(id);
    if (practice != null) {
      await savePractice(practice.copyWith(
        useCount: practice.useCount + 1,
        lastUsedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  /// Intelligence Ranking (Section 8, 32, 33)
  /// Considers:
  /// 1. Pinned
  /// 2. Favorites
  /// 3. Time-of-day relevance
  /// 4. Recent use
  /// 5. Frequency of use
  List<Practice> rankPractices(List<Practice> practices, {DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;

    // Time-of-day affinity
    bool isMorning(Practice p) =>
        p.type == MeditationType.breathing ||
        p.type == MeditationType.focus ||
        p.name.toLowerCase().contains('morning');
    bool isEvening(Practice p) =>
        p.type == MeditationType.sleep ||
        p.type == MeditationType.openAwareness ||
        p.name.toLowerCase().contains('evening') ||
        p.name.toLowerCase().contains('reset');

    final list = List<Practice>.from(practices);

    list.sort((a, b) {
      // 1. Pinned first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // 2. Favorites second
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      // 3. Time of day matching
      if (hour >= 5 && hour < 12) {
        // Morning (5am - 12pm)
        if (isMorning(a) && !isMorning(b)) return -1;
        if (!isMorning(a) && isMorning(b)) return 1;
      } else if (hour >= 18 || hour < 4) {
        // Evening / Night (6pm - 4am)
        if (isEvening(a) && !isEvening(b)) return -1;
        if (!isEvening(a) && isEvening(b)) return 1;
      }

      // 4. Recently used
      if (a.lastUsedAt != null && b.lastUsedAt != null) {
        final cmp = b.lastUsedAt!.compareTo(a.lastUsedAt!);
        if (cmp != 0) return cmp;
      } else if (a.lastUsedAt != null && b.lastUsedAt == null) {
        return -1;
      } else if (a.lastUsedAt == null && b.lastUsedAt != null) {
        return 1;
      }

      // 5. Use count
      if (b.useCount != a.useCount) {
        return b.useCount.compareTo(a.useCount);
      }

      // Default alphabetical
      return a.name.compareTo(b.name);
    });

    return list;
  }
}
