import 'package:flutter/material.dart';
import '../data/database/database.dart';
import '../data/models/practice.dart';
import '../data/repositories/practice_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/achievement_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../core/audio/audio_service.dart';
import '../core/notifications/notification_service.dart';
import '../core/theme/app_theme.dart';
import '../core/responsive/responsive_layout.dart';
import '../features/meditate/screens/meditate_home_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/progress/screens/progress_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/meditation_session/controllers/session_controller.dart';
import '../features/meditation_session/screens/active_meditation_screen.dart';

class StillnessApp extends StatefulWidget {
  final AppDatabase database;
  final PracticeRepository practiceRepo;
  final SessionRepository sessionRepo;
  final AchievementRepository achievementRepo;
  final SettingsRepository settingsRepo;
  final AppAudioService audioService;
  final NotificationService notificationService;

  const StillnessApp({
    super.key,
    required this.database,
    required this.practiceRepo,
    required this.sessionRepo,
    required this.achievementRepo,
    required this.settingsRepo,
    required this.audioService,
    required this.notificationService,
  });

  @override
  State<StillnessApp> createState() => _StillnessAppState();
}

class _StillnessAppState extends State<StillnessApp> {
  ThemeMode _themeMode = ThemeMode.system;
  int _currentIndex = 0;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  void _loadInitialSettings() async {
    final settings = await widget.settingsRepo.getSettings();
    setState(() {
      _themeMode = settings.themeMode;
    });
  }

  void _startMeditation(Practice practice) {
    final controller = SessionController(
      practice: practice,
      practiceRepo: widget.practiceRepo,
      sessionRepo: widget.sessionRepo,
      achievementRepo: widget.achievementRepo,
      audioService: widget.audioService,
    );

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (ctx) => ActiveMeditationScreen(controller: controller),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Stillness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: Builder(
        builder: (context) {
          final pages = [
            MeditateHomeScreen(
              practiceRepo: widget.practiceRepo,
              sessionRepo: widget.sessionRepo,
              audioService: widget.audioService,
              onStartPractice: _startMeditation,
            ),
            HistoryScreen(
              sessionRepo: widget.sessionRepo,
              onStartPractice: _startMeditation,
            ),
            ProgressScreen(
              sessionRepo: widget.sessionRepo,
              achievementRepo: widget.achievementRepo,
            ),
            SettingsScreen(
              settingsRepo: widget.settingsRepo,
              notificationService: widget.notificationService,
              onThemeChanged: (mode) => setState(() => _themeMode = mode),
            ),
          ];

          return ResponsiveScaffold(
            selectedIndex: _currentIndex,
            onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
            destinations: const [
              NavigationDestinationItem(
                icon: Icon(Icons.self_improvement_outlined),
                selectedIcon: Icon(Icons.self_improvement_rounded),
                label: 'Meditate',
              ),
              NavigationDestinationItem(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today_rounded),
                label: 'History',
              ),
              NavigationDestinationItem(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Progress',
              ),
              NavigationDestinationItem(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
            body: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          );
        },
      ),
    );
  }
}
