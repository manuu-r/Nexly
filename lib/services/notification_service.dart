import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static const MethodChannel _channel =
      MethodChannel('com.nexly/notifications');
  static final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  static Stream<Map<String, dynamic>> get notificationStream =>
      _streamController.stream;

  static Future<void> requestPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      await openAppSettings();
    }
  }

  static void startListening() {
    _channel.setMethodCallHandler(_handleMethod);
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onNotificationPosted':
        _streamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      case 'onNotificationRemoved':
        _streamController.add(Map<String, dynamic>.from(call.arguments));
        break;
      default:
        throw MissingPluginException('notImplemented');
    }
  }
}
