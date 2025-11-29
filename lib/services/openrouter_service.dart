import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for AI summarization using OpenRouter API
/// Supports Anthropic Claude and Google Gemini models
class OpenRouterService {
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  // Preferred models in order of preference
  static const List<String> _models = [
    'anthropic/claude-3.5-sonnet',
    'google/gemini-flash-1.5',
    'google/gemini-pro-1.5',
  ];

  static int _currentModelIndex = 0;

  /// Get the API key from environment variables
  static String? get _apiKey => dotenv.env['OPENROUTER_API_KEY'];

  /// Summarize a list of notifications using OpenRouter AI
  static Future<String> summarize(List<String> notifications) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('OpenRouter API key not found in .env file');
      return 'API key not configured. Unable to generate summary.';
    }

    if (notifications.isEmpty) {
      return 'No notifications to summarize.';
    }

    try {
      final prompt = _buildPrompt(notifications);
      final response = await _makeRequest(prompt);

      if (response != null) {
        return response;
      } else {
        return 'Unable to generate summary at this time.';
      }
    } catch (e) {
      debugPrint('OpenRouter error: $e');
      return 'Error generating summary: ${e.toString()}';
    }
  }

  /// Build the prompt for notification summarization
  static String _buildPrompt(List<String> notifications) {
    final notificationList = notifications.take(20).join('\n• ');
    final remaining = notifications.length > 20 ? notifications.length - 20 : 0;

    return '''You are a helpful assistant that creates concise summaries of phone notifications.

Notifications received:
• $notificationList${remaining > 0 ? '\n... and $remaining more notifications' : ''}

Provide a brief, helpful 2-3 sentence summary highlighting the most important notifications and key themes.''';
  }

  /// Make HTTP request to OpenRouter API with model fallback
  static Future<String?> _makeRequest(String prompt) async {
    for (int i = _currentModelIndex; i < _models.length; i++) {
      final model = _models[i];
      debugPrint('Trying OpenRouter model: $model');

      try {
        final response = await http
            .post(
              Uri.parse(_baseUrl),
              headers: {
                'Authorization': 'Bearer $_apiKey',
                'Content-Type': 'application/json',
                'HTTP-Referer': 'https://github.com/nexly-app',
                'X-Title': 'Nexly Notification Secretary',
              },
              body: jsonEncode({
                'model': model,
                'messages': [
                  {'role': 'user', 'content': prompt},
                ],
                'max_tokens': 256,
                'temperature': 0.7,
              }),
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final summary =
              data['choices']?[0]?['message']?['content'] as String?;

          if (summary != null && summary.isNotEmpty) {
            _currentModelIndex = i; // Remember successful model
            debugPrint('Successfully generated summary with $model');
            return summary.trim();
          }
        } else {
          debugPrint(
            'OpenRouter API error (${response.statusCode}): ${response.body}',
          );

          // If it's a model-specific error, try next model
          if (response.statusCode == 400 || response.statusCode == 404) {
            continue;
          }

          // For other errors, return null
          return null;
        }
      } catch (e) {
        debugPrint('Error with model $model: $e');
        // Try next model
        continue;
      }
    }

    // All models failed
    debugPrint('All OpenRouter models failed');
    return null;
  }

  /// Test the OpenRouter service with a simple prompt
  static Future<String> test() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'API key not configured';
    }

    try {
      final response = await _makeRequest(
        'Respond with exactly two words: "Service working"',
      );

      return response ?? 'Test failed - no response';
    } catch (e) {
      return 'Test error: ${e.toString()}';
    }
  }

  /// Check if the service is properly configured
  static bool get isConfigured => _apiKey != null && _apiKey!.isNotEmpty;
}
