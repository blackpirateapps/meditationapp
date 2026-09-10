import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(settings: initSettings);

      // Create Android Notification Channels
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'meditation_reminders',
            'Meditation Reminders',
            description: 'Gentle daily reminders for your meditation practice',
            importance: Importance.defaultImportance,
          ),
        );

        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'meditation_session',
            'Active Meditation',
            description: 'Playback and timer for active meditation sessions',
            importance: Importance.low,
            playSound: false,
            enableVibration: false,
          ),
        );
      }

      _initialized = true;
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  Future<bool> requestPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String scheduleType, // 'daily' or 'weekdays'
  }) async {
    await cancelReminders();
    if (scheduleType == 'off') return;

    try {
      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'meditation_reminders',
        'Meditation Reminders',
        channelDescription: 'Gentle daily reminders for your meditation practice',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const details = NotificationDetails(android: androidDetails);

      final tzLocation = tz.local;
      final tzDateTime = tz.TZDateTime.from(scheduledDate, tzLocation);

      await _notificationsPlugin.zonedSchedule(
        id: 1001,
        title: 'Take a moment',
        body: 'Your meditation is ready.',
        scheduledDate: tzDateTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: scheduleType == 'weekdays'
            ? DateTimeComponents.dayOfWeekAndTime
            : DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
    }
  }

  Future<void> cancelReminders() async {
    try {
      await _notificationsPlugin.cancel(id: 1001);
    } catch (_) {}
  }
}
