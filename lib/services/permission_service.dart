import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

/// Service for managing app permissions
/// Handles notification access, boot permission, and post notifications
class PermissionService {
  // Platform channel for notification listener permission
  static const _channel = MethodChannel('com.nexly/notifications');

  /// Check if notification listener permission is granted
  static Future<bool> isNotificationListenerEnabled() async {
    try {
      final bool isEnabled = await _channel.invokeMethod(
        'isNotificationListenerEnabled',
      );
      return isEnabled;
    } catch (e) {
      debugPrint('Error checking notification listener permission: $e');
      return false;
    }
  }

  /// Open notification listener settings
  static Future<void> openNotificationListenerSettings() async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (e) {
      debugPrint('Error opening notification listener settings: $e');
    }
  }

  /// Check if POST_NOTIFICATIONS permission is granted (Android 13+)
  static Future<bool> isPostNotificationsGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking post notifications permission: $e');
      return false;
    }
  }

  /// Request POST_NOTIFICATIONS permission
  static Future<bool> requestPostNotifications() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting post notifications permission: $e');
      return false;
    }
  }

  /// Open app settings
  static Future<void> openSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  /// Check all required permissions
  static Future<PermissionStatus> checkAllPermissions() async {
    final notificationListener = await isNotificationListenerEnabled();
    final postNotifications = await isPostNotificationsGranted();

    return PermissionStatus(
      notificationListener: notificationListener,
      postNotifications: postNotifications,
    );
  }

  /// Request all missing permissions
  static Future<void> requestAllPermissions() async {
    // Check and request POST_NOTIFICATIONS first (Android 13+)
    final postNotificationsGranted = await isPostNotificationsGranted();
    if (!postNotificationsGranted) {
      await requestPostNotifications();
    }

    // Check notification listener - if not enabled, open settings
    final notificationListenerEnabled = await isNotificationListenerEnabled();
    if (!notificationListenerEnabled) {
      await openNotificationListenerSettings();
    }
  }
}

/// Permission status data class
class PermissionStatus {
  final bool notificationListener;
  final bool postNotifications;

  const PermissionStatus({
    required this.notificationListener,
    required this.postNotifications,
  });

  /// Check if all required permissions are granted
  bool get allGranted => notificationListener && postNotifications;

  /// Get list of missing permissions
  List<String> get missingPermissions {
    final missing = <String>[];
    if (!notificationListener) missing.add('Notification Access');
    if (!postNotifications) missing.add('Post Notifications');
    return missing;
  }
}
