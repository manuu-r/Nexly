import 'package:flutter/foundation.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:hive/hive.dart';
import '../models/notification_item.dart';

class NotificationService {
  static const String _boxName = 'notifications';

  /// Initialize the notification listener
  static Future<void> initialize() async {
    try {
      // Start listening to notifications
      NotificationsListener.initialize(callbackHandle: onNotificationReceived);
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  /// Callback for when a notification is received
  /// This runs in a background isolate
  @pragma('vm:entry-point')
  static void onNotificationReceived(NotificationEvent event) async {
    try {
      // Filter out system and low-priority notifications
      if (_shouldIgnoreNotification(event)) {
        return;
      }

      // Open Hive box in the background isolate
      if (!Hive.isBoxOpen(_boxName)) {
        // Initialize Hive for background isolate
        Hive.registerAdapter(NotificationItemAdapter());
        await Hive.openBox<NotificationItem>(_boxName);
      }

      final box = Hive.box<NotificationItem>(_boxName);

      // Create notification item
      final notificationItem = NotificationItem(
        id: '${event.packageName}_${DateTime.now().millisecondsSinceEpoch}',
        packageName: event.packageName ?? 'unknown',
        title: event.title ?? 'No title',
        body: event.text ?? '',
        timestamp: DateTime.now(),
      );

      // Save to Hive
      await box.add(notificationItem);
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  /// Filter logic to ignore certain notifications
  static bool _shouldIgnoreNotification(NotificationEvent event) {
    // Ignore if package name is null
    if (event.packageName == null) return true;

    // Ignore system notifications
    if (event.packageName!.startsWith('android')) return true;
    if (event.packageName!.startsWith('com.android')) return true;

    // Ignore if both title and text are empty
    if ((event.title == null || event.title!.isEmpty) &&
        (event.text == null || event.text!.isEmpty)) {
      return true;
    }

    return false;
  }

  /// Get all notifications
  static List<NotificationItem> getAllNotifications() {
    final box = Hive.box<NotificationItem>(_boxName);
    return box.values.toList();
  }

  /// Clear all notifications
  static Future<void> clearAll() async {
    final box = Hive.box<NotificationItem>(_boxName);
    await box.clear();
  }

  /// Mark notification as read
  static Future<void> markAsRead(String id) async {
    final box = Hive.box<NotificationItem>(_boxName);
    final notification = box.values.firstWhere((n) => n.id == id);
    notification.isRead = true;
    await notification.save();
  }
}
