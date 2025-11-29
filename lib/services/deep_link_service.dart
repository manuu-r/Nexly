import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

/// Service for creating deep links to other apps
/// Parses notification content and creates appropriate intents
class DeepLinkService {
  /// Parse notification content and return possible actions
  static List<DeepLinkAction> parseActions(String title, String body) {
    final actions = <DeepLinkAction>[];
    final content = '$title $body'.toLowerCase();

    // Check for phone numbers
    final phoneNumbers = _extractPhoneNumbers(body);
    for (final number in phoneNumbers) {
      actions.add(
        DeepLinkAction(
          type: DeepLinkType.phone,
          label: 'Call $number',
          data: number,
        ),
      );
    }

    // Check for email addresses
    final emails = _extractEmails(body);
    for (final email in emails) {
      actions.add(
        DeepLinkAction(
          type: DeepLinkType.email,
          label: 'Email $email',
          data: email,
        ),
      );
    }

    // Check for URLs
    final urls = _extractUrls(body);
    for (final url in urls) {
      actions.add(
        DeepLinkAction(type: DeepLinkType.url, label: 'Open link', data: url),
      );
    }

    // Check for calendar-related keywords
    if (_containsCalendarKeywords(content)) {
      actions.add(
        DeepLinkAction(
          type: DeepLinkType.calendar,
          label: 'Add to calendar',
          data: title,
        ),
      );
    }

    // Check for SMS-related keywords
    if (_containsSmsKeywords(content) && phoneNumbers.isNotEmpty) {
      actions.add(
        DeepLinkAction(
          type: DeepLinkType.sms,
          label: 'Send message',
          data: phoneNumbers.first,
        ),
      );
    }

    return actions;
  }

  /// Execute a deep link action
  static Future<bool> executeAction(DeepLinkAction action) async {
    try {
      switch (action.type) {
        case DeepLinkType.phone:
          return await _openPhone(action.data);
        case DeepLinkType.email:
          return await _openEmail(action.data);
        case DeepLinkType.sms:
          return await _openSms(action.data);
        case DeepLinkType.calendar:
          return await _openCalendar(action.data);
        case DeepLinkType.url:
          return await _openUrl(action.data);
      }
    } catch (e) {
      debugPrint('Error executing deep link action: $e');
      return false;
    }
  }

  // Phone intent
  static Future<bool> _openPhone(String phoneNumber) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.DIAL',
        data: 'tel:$phoneNumber',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('Error opening phone: $e');
      return false;
    }
  }

  // Email intent
  static Future<bool> _openEmail(String email) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SENDTO',
        data: 'mailto:$email',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('Error opening email: $e');
      return false;
    }
  }

  // SMS intent
  static Future<bool> _openSms(String phoneNumber) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.SENDTO',
        data: 'smsto:$phoneNumber',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('Error opening SMS: $e');
      return false;
    }
  }

  // Calendar intent
  static Future<bool> _openCalendar(String title) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.INSERT',
        data: 'content://com.android.calendar/events',
        arguments: {'title': title},
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('Error opening calendar: $e');
      return false;
    }
  }

  // URL intent
  static Future<bool> _openUrl(String url) async {
    try {
      final intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: url,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } catch (e) {
      debugPrint('Error opening URL: $e');
      return false;
    }
  }

  // Pattern matching helpers
  static List<String> _extractPhoneNumbers(String text) {
    final phoneRegex = RegExp(
      r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b|\b\(\d{3}\)\s?\d{3}[-.]?\d{4}\b',
    );
    return phoneRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  static List<String> _extractEmails(String text) {
    final emailRegex = RegExp(
      r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b',
    );
    return emailRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  static List<String> _extractUrls(String text) {
    final urlRegex = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    return urlRegex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  static bool _containsCalendarKeywords(String text) {
    final keywords = [
      'meeting',
      'appointment',
      'scheduled',
      'event',
      'reminder',
      'calendar',
      'invite',
      'rsvp',
      'conference',
      'call at',
    ];
    return keywords.any((keyword) => text.contains(keyword));
  }

  static bool _containsSmsKeywords(String text) {
    final keywords = ['message', 'text', 'sms', 'reply', 'respond'];
    return keywords.any((keyword) => text.contains(keyword));
  }
}

/// Types of deep link actions
enum DeepLinkType { phone, email, sms, calendar, url }

/// Deep link action data class
class DeepLinkAction {
  final DeepLinkType type;
  final String label;
  final String data;

  const DeepLinkAction({
    required this.type,
    required this.label,
    required this.data,
  });
}
