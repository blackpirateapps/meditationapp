import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:meditationapp/data/database/database.dart';
import 'package:meditationapp/data/repositories/practice_repository.dart';
import 'package:meditationapp/data/repositories/session_repository.dart';
import 'package:meditationapp/data/repositories/achievement_repository.dart';
import 'package:meditationapp/data/repositories/settings_repository.dart';
import 'package:meditationapp/core/audio/audio_service.dart';
import 'package:meditationapp/core/notifications/notification_service.dart';
import 'package:meditationapp/app/app.dart';

void main() {
  late AppDatabase db;
  late PracticeRepository practiceRepo;
  late SessionRepository sessionRepo;
  late AchievementRepository achievementRepo;
  late SettingsRepository settingsRepo;
  late AppAudioService audioService;
  late NotificationService notificationService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    practiceRepo = PracticeRepository(db);
    await practiceRepo.initDefaults();

    sessionRepo = SessionRepository(db);
    achievementRepo = AchievementRepository(db);
    settingsRepo = SettingsRepository(db);
    audioService = AppAudioService();
    notificationService = NotificationService();
  });

  tearDown(() async {
    audioService.dispose();
    await db.close();
  });

  testWidgets('StillnessApp renders navigation and switches tabs',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      StillnessApp(
        database: db,
        practiceRepo: practiceRepo,
        sessionRepo: sessionRepo,
        achievementRepo: achievementRepo,
        settingsRepo: settingsRepo,
        audioService: audioService,
        notificationService: notificationService,
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial destination is Meditate
    expect(find.text('Meditate'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);

    // Switch to History tab
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Sessions'), findsWidgets);

    // Switch to Progress tab
    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL TIME'), findsWidgets);

    // Switch to Settings tab
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsWidgets);
    expect(find.text('Meditation Defaults'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('Tablet layout renders NavigationRail',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      StillnessApp(
        database: db,
        practiceRepo: practiceRepo,
        sessionRepo: sessionRepo,
        achievementRepo: achievementRepo,
        settingsRepo: settingsRepo,
        audioService: audioService,
        notificationService: notificationService,
      ),
    );

    await tester.pumpAndSettle();

    // Verify NavigationRail is used instead of NavigationBar
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
