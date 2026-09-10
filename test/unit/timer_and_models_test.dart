import 'package:flutter_test/flutter_test.dart';
import 'package:meditationapp/data/models/breathing_config.dart';
import 'package:meditationapp/data/models/meditation_type.dart';
import 'package:meditationapp/data/models/practice.dart';
import 'package:meditationapp/data/models/meditation_session.dart';
import 'package:meditationapp/data/models/session_snapshot.dart';
import 'package:meditationapp/data/models/achievement.dart';
import 'package:meditationapp/data/models/export_data.dart';
import 'package:meditationapp/data/database/database.dart';
import 'package:meditationapp/data/repositories/session_repository.dart';
import 'package:meditationapp/data/repositories/practice_repository.dart';
import 'package:drift/native.dart';

void main() {
  group('BreathingConfig & Cycle Timing Tests', () {
    test('Box breathing cycle calculation', () {
      const config = BreathingConfig.box;
      expect(config.cycleDurationSeconds, 16);
      expect(config.inhaleSeconds, 4);
      expect(config.inhaleHoldSeconds, 4);
      expect(config.exhaleSeconds, 4);
      expect(config.exhaleHoldSeconds, 4);
    });

    test('Custom breathing cycle calculation', () {
      const config = BreathingConfig(
        inhaleSeconds: 5,
        inhaleHoldSeconds: 2,
        exhaleSeconds: 7,
        exhaleHoldSeconds: 1,
      );
      expect(config.cycleDurationSeconds, 15);
    });

    test('BreathingConfig JSON serialization roundtrip', () {
      const config = BreathingConfig(
        inhaleSeconds: 4,
        inhaleHoldSeconds: 7,
        exhaleSeconds: 8,
        exhaleHoldSeconds: 0,
        presetName: '4-7-8',
      );
      final json = config.toJson();
      final restored = BreathingConfig.fromJson(json);
      expect(restored.inhaleSeconds, 4);
      expect(restored.inhaleHoldSeconds, 7);
      expect(restored.exhaleSeconds, 8);
      expect(restored.exhaleHoldSeconds, 0);
      expect(restored.presetName, '4-7-8');
    });
  });

  group('Practice & Session Snapshot Integrity Tests (Section 38)', () {
    test('Practice creates faithful immutable SessionSnapshot', () {
      final now = DateTime(2026, 9, 10, 10, 0);
      final practice = Practice(
        id: 'p_test_1',
        name: 'Evening Calm',
        description: 'Quiet awareness session',
        type: MeditationType.openAwareness,
        durationSeconds: 1200,
        preparationSeconds: 15,
        backgroundSound: 'nature_fireplace',
        backgroundSoundVolume: 0.4,
        endingSound: 'bell_tingsha',
        intervalBellEnabled: true,
        intervalBellIntervalSeconds: 300,
        createdAt: now,
        updatedAt: now,
      );

      final snapshot = practice.toSnapshot();
      expect(snapshot.practiceId, 'p_test_1');
      expect(snapshot.practiceName, 'Evening Calm');
      expect(snapshot.meditationType, MeditationType.openAwareness);
      expect(snapshot.plannedDurationSeconds, 1200);
      expect(snapshot.backgroundSound, 'nature_fireplace');
      expect(snapshot.intervalBellIntervalSeconds, 300);

      // Verify snapshot serialization roundtrip
      final snapJson = snapshot.toJson();
      final restoredSnap = SessionSnapshot.fromJson(snapJson);
      expect(restoredSnap.practiceName, 'Evening Calm');
      expect(restoredSnap.plannedDurationSeconds, 1200);
      expect(restoredSnap.backgroundSound, 'nature_fireplace');
    });

    test('Practice JSON roundtrip preserves all fields', () {
      final now = DateTime(2026, 9, 10, 12, 0);
      final practice = Practice(
        id: 'p_roundtrip',
        name: 'Test Breathing',
        description: 'Desc',
        type: MeditationType.breathing,
        durationSeconds: 600,
        breathingConfig: BreathingConfig.box,
        createdAt: now,
        updatedAt: now,
        isFavorite: true,
        isPinned: true,
        useCount: 5,
      );

      final json = practice.toJson();
      final restored = Practice.fromJson(json);

      expect(restored.id, 'p_roundtrip');
      expect(restored.name, 'Test Breathing');
      expect(restored.isFavorite, true);
      expect(restored.isPinned, true);
      expect(restored.useCount, 5);
      expect(restored.breathingConfig?.cycleDurationSeconds, 16);
    });
  });

  group('Statistics & Streak Engine Tests (Section 55)', () {
    late AppDatabase db;
    late SessionRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SessionRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Empty sessions return zero stats', () {
      final stats = repo.calculateStats([]);
      expect(stats.totalSessions, 0);
      expect(stats.totalSeconds, 0);
      expect(stats.averageSeconds, 0);
      expect(stats.daysMeditated, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('Calculates total, averages, and days correctly', () {
      final ref = DateTime(2026, 9, 10, 20, 0);
      final sessions = [
        MeditationSession(
          id: 's1',
          practiceId: 'p1',
          startedAt: DateTime(2026, 9, 10, 8, 0),
          completedAt: DateTime(2026, 9, 10, 8, 20),
          plannedDurationSeconds: 1200,
          actualDurationSeconds: 1200,
          status: SessionStatus.completed,
          snapshot: const SessionSnapshot(
            practiceId: 'p1',
            practiceName: 'Sit',
            meditationType: MeditationType.openAwareness,
            plannedDurationSeconds: 1200,
          ),
        ),
        MeditationSession(
          id: 's2',
          practiceId: 'p1',
          startedAt: DateTime(2026, 9, 10, 18, 0),
          completedAt: DateTime(2026, 9, 10, 18, 10),
          plannedDurationSeconds: 600,
          actualDurationSeconds: 600,
          status: SessionStatus.completed,
          snapshot: const SessionSnapshot(
            practiceId: 'p1',
            practiceName: 'Sit',
            meditationType: MeditationType.breathing,
            plannedDurationSeconds: 600,
          ),
        ),
      ];

      final stats = repo.calculateStats(sessions, referenceDate: ref);
      expect(stats.totalSessions, 2);
      expect(stats.totalSeconds, 1800);
      expect(stats.averageSeconds, 900);
      expect(stats.daysMeditated, 1);
      expect(stats.typeSeconds[MeditationType.openAwareness], 1200);
      expect(stats.typeSeconds[MeditationType.breathing], 600);
    });

    test('Calculates multi-day streaks and gaps correctly', () {
      final ref = DateTime(2026, 9, 10, 12, 0);
      // 3 consecutive days: Sep 8, Sep 9, Sep 10
      final sessions = [
        MeditationSession(
          id: 's1',
          practiceId: 'p1',
          startedAt: DateTime(2026, 9, 8, 9, 0),
          completedAt: DateTime(2026, 9, 8, 9, 10),
          plannedDurationSeconds: 600,
          actualDurationSeconds: 600,
          status: SessionStatus.completed,
          snapshot: const SessionSnapshot(
            practiceId: 'p1',
            practiceName: 'Sit',
            meditationType: MeditationType.silentTimer,
            plannedDurationSeconds: 600,
          ),
        ),
        MeditationSession(
          id: 's2',
          practiceId: 'p1',
          startedAt: DateTime(2026, 9, 9, 9, 0),
          completedAt: DateTime(2026, 9, 9, 9, 10),
          plannedDurationSeconds: 600,
          actualDurationSeconds: 600,
          status: SessionStatus.completed,
          snapshot: const SessionSnapshot(
            practiceId: 'p1',
            practiceName: 'Sit',
            meditationType: MeditationType.silentTimer,
            plannedDurationSeconds: 600,
          ),
        ),
        MeditationSession(
          id: 's3',
          practiceId: 'p1',
          startedAt: DateTime(2026, 9, 10, 9, 0),
          completedAt: DateTime(2026, 9, 10, 9, 10),
          plannedDurationSeconds: 600,
          actualDurationSeconds: 600,
          status: SessionStatus.completed,
          snapshot: const SessionSnapshot(
            practiceId: 'p1',
            practiceName: 'Sit',
            meditationType: MeditationType.silentTimer,
            plannedDurationSeconds: 600,
          ),
        ),
      ];

      final stats = repo.calculateStats(sessions, referenceDate: ref);
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
    });
  });

  group('Practice Adaptive Intelligence Ranking (Section 32 & 33)', () {
    late AppDatabase db;
    late PracticeRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = PracticeRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Pinned practices are ranked first', () {
      final now = DateTime.now();
      final p1 = Practice(
        id: '1',
        name: 'Regular',
        description: '',
        type: MeditationType.silentTimer,
        durationSeconds: 600,
        createdAt: now,
        updatedAt: now,
        isPinned: false,
      );
      final p2 = Practice(
        id: '2',
        name: 'Pinned Practice',
        description: '',
        type: MeditationType.silentTimer,
        durationSeconds: 600,
        createdAt: now,
        updatedAt: now,
        isPinned: true,
      );

      final ranked = repo.rankPractices([p1, p2]);
      expect(ranked.first.id, '2');
    });

    test('Morning time-of-day prioritizes breathing and focus', () {
      final morningTime = DateTime(2026, 9, 10, 7, 30); // 7:30 AM
      final pSleep = Practice(
        id: 'sleep',
        name: 'Sleep Practice',
        description: '',
        type: MeditationType.sleep,
        durationSeconds: 1800,
        createdAt: morningTime,
        updatedAt: morningTime,
      );
      final pBreath = Practice(
        id: 'breath',
        name: 'Morning Breathing',
        description: '',
        type: MeditationType.breathing,
        durationSeconds: 600,
        createdAt: morningTime,
        updatedAt: morningTime,
      );

      final ranked = repo.rankPractices([pSleep, pBreath], currentTime: morningTime);
      expect(ranked.first.id, 'breath');
    });
  });

  group('Backup Archive Export & Import Validation (Section 39 & 89)', () {
    test('ExportData serializes and deserializes accurately', () {
      final now = DateTime(2026, 9, 10, 10, 0);
      final export = ExportData(
        schemaVersion: 1,
        exportedAt: now,
        practices: [
          Practice(
            id: 'p_exp',
            name: 'Exported Practice',
            description: '',
            type: MeditationType.focus,
            durationSeconds: 900,
            createdAt: now,
            updatedAt: now,
          ),
        ],
        sessions: [
          MeditationSession(
            id: 's_exp',
            practiceId: 'p_exp',
            startedAt: now,
            completedAt: now.add(const Duration(minutes: 15)),
            plannedDurationSeconds: 900,
            actualDurationSeconds: 900,
            status: SessionStatus.completed,
            mood: 'peaceful',
            note: 'Felt deep clarity',
            snapshot: const SessionSnapshot(
              practiceId: 'p_exp',
              practiceName: 'Exported Practice',
              meditationType: MeditationType.focus,
              plannedDurationSeconds: 900,
            ),
          ),
        ],
        achievements: [
          Achievement(
            id: 'first_breath',
            title: 'First Breath',
            description: '',
            category: 'milestone',
            threshold: 1,
            unlockedAt: now,
          ),
        ],
      );

      final jsonStr = export.toJsonString();
      final restored = ExportData.fromJsonString(jsonStr);

      expect(restored.schemaVersion, 1);
      expect(restored.practices.length, 1);
      expect(restored.practices.first.name, 'Exported Practice');
      expect(restored.sessions.length, 1);
      expect(restored.sessions.first.note, 'Felt deep clarity');
      expect(restored.achievements.first.unlockedAt, isNotNull);
    });

    test('Rejects unsupported future schema versions', () {
      const invalidJson = '''
      {
        "schemaVersion": 99,
        "exportedAt": "2026-09-10T10:00:00.000",
        "practices": [],
        "sessions": [],
        "achievements": []
      }
      ''';

      expect(
        () => ExportData.fromJsonString(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
