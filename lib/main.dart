import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/database/database.dart';
import 'data/repositories/practice_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/achievement_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'core/audio/audio_service.dart';
import 'core/notifications/notification_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer edge-to-edge transparent system navigation bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize Drift Local Database
  final database = AppDatabase();

  // Initialize Repositories
  final practiceRepo = PracticeRepository(database);
  await practiceRepo.initDefaults();

  final sessionRepo = SessionRepository(database);
  final achievementRepo = AchievementRepository(database);
  final settingsRepo = SettingsRepository(database);

  // Initialize Audio & Notifications
  final audioService = AppAudioService();
  await audioService.initialize();

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    StillnessApp(
      database: database,
      practiceRepo: practiceRepo,
      sessionRepo: sessionRepo,
      achievementRepo: achievementRepo,
      settingsRepo: settingsRepo,
      audioService: audioService,
      notificationService: notificationService,
    ),
  );
}
