import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Service for scheduling daily summary notifications
class NotificationScheduler {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'nexly_daily_summary';
  static const String _channelName = 'Daily Summary';
  static const String _channelDescription =
      'Notifications for daily summary reminders';
  static const int _notificationId = 0;
  static const String _summaryTimeKey = 'daily_summary_time';

  /// Initialize the notification scheduler
  static Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);

      debugPrint('Notification scheduler initialized');

      // Schedule the daily notification
      await scheduleDailySummary();
    } catch (e) {
      debugPrint('Error initializing notification scheduler: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // The payload contains the route to navigate to
    // This will be handled by the main app's navigation
  }

  /// Schedule daily summary notification at specified time
  static Future<void> scheduleDailySummary({
    int hour = 20,
    int minute = 0,
  }) async {
    try {
      // Save the time preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_summaryTimeKey, hour * 60 + minute);

      // Cancel existing scheduled notification
      await _notifications.cancel(_notificationId);

      // Calculate next scheduled time
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Schedule the notification
      await _notifications.zonedSchedule(
        _notificationId,
        'Daily Summary Ready',
        'Tap to view your notification summary',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: '/summary', // Route to navigate to
      );

      debugPrint(
        'Daily summary scheduled for $hour:${minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      debugPrint('Error scheduling daily summary: $e');
    }
  }

  /// Get the currently scheduled summary time
  static Future<SummaryTime> getSummaryTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final minutes =
          prefs.getInt(_summaryTimeKey) ?? (20 * 60); // Default 8 PM
      return SummaryTime(hour: minutes ~/ 60, minute: minutes % 60);
    } catch (e) {
      debugPrint('Error getting summary time: $e');
      return const SummaryTime(hour: 20, minute: 0);
    }
  }

  /// Update the summary time
  static Future<void> updateSummaryTime(int hour, int minute) async {
    await scheduleDailySummary(hour: hour, minute: minute);
  }

  /// Show immediate test notification
  static Future<void> showTestNotification() async {
    try {
      await _notifications.show(
        999, // Different ID for test
        'Test Notification',
        'This is a test notification from Nexly',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: '/summary',
      );
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
    debugPrint('All scheduled notifications canceled');
  }
}

/// Summary time data class
class SummaryTime {
  final int hour;
  final int minute;

  const SummaryTime({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
