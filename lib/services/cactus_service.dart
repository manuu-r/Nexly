import 'package:flutter/foundation.dart';
import 'package:cactus/cactus.dart';
import 'openrouter_service.dart';

/// Service for AI-powered notification summarization
/// Hybrid approach: Tries local Cactus model first, falls back to OpenRouter cloud API
class CactusAIService {
  static CactusLM? _model;
  static const String _modelSlug =
      'gemma3-1b'; // NOTE: This is a guess based on the new API

  /// Initialize Cactus with the Gemma 3 1B model
  /// Uses ~1GB RAM, optimized for mobile devices
  static Future<void> initialize() async {
    try {
      _model = CactusLM();
      // Download gemma-3-1b model if not already present
      await _model!.downloadModel(model: _modelSlug);

      // Initialize the model with mobile-optimized settings
      await _model!.initializeModel(
        params: CactusInitParams(
          model: _modelSlug,
          contextSize: 2048, // Smaller context for efficiency
        ),
      );

      debugPrint('Cactus AI service initialized with gemma-3-1b');
    } catch (e) {
      debugPrint('Error initializing Cactus: $e');
    }
  }

  static Future<String> runTestPrompt({
    String prompt =
        'Summarize the following in one sentence: Today I received several messages about meetings, a delivery, and a reminder to pay a bill.',
  }) async {
    if (_model == null) {
      return 'AI not initialized. Call initialize() first.';
    }

    try {
      final testPrompt =
          '''You are a helpful assistant that responds concisely.
Respond to the prompt below in 2 words exactly.

Prompt:
$prompt

Keep the response short and clear.''';

      final result = await _model!.generateCompletion(
        messages: [ChatMessage(content: testPrompt, role: 'user')],
        params: CactusCompletionParams(maxTokens: 256, temperature: 0.7),
      );

      if (result.success) {
        debugPrint('Cactus test prompt completed: ${result.toString()}');
        return result.response.trim();
      } else {
        debugPrint('Error running test prompt: generation failed');
        return 'Error running test prompt.';
      }
    } catch (e) {
      debugPrint('Error running test prompt: $e');
      return 'Error running test prompt.';
    }
  }

  /// Summarize notifications using hybrid approach
  /// First tries local Cactus model, falls back to OpenRouter if local fails
  static Future<String> summarizeNotifications(
    List<String> notifications,
  ) async {
    if (notifications.isEmpty) {
      return 'No notifications to summarize.';
    }

    // Try local Cactus first if initialized
    if (isInitialized) {
      try {
        debugPrint('Attempting local Cactus summarization...');
        final localSummary = await _summarizeWithLocalModel(notifications);

        // If we got a valid summary (not an error message), return it
        if (localSummary != null &&
            !localSummary.contains('Unable to generate') &&
            !localSummary.contains('Error')) {
          debugPrint('Local Cactus summarization successful');
          return localSummary;
        }
      } catch (e) {
        debugPrint('Local Cactus failed: $e, falling back to OpenRouter');
      }
    } else {
      debugPrint('Local Cactus not initialized, using OpenRouter');
    }

    // Fallback to OpenRouter
    try {
      debugPrint('Using OpenRouter fallback for summarization');
      return await OpenRouterService.summarize(
        notifications.map((n) => '• $n').toList(),
      );
    } catch (e) {
      debugPrint('OpenRouter fallback failed: $e');
      return 'Unable to generate summary. Both local and cloud AI failed.';
    }
  }

  /// Internal method for local Cactus summarization
  static Future<String?> _summarizeWithLocalModel(
    List<String> notifications,
  ) async {
    try {
      final prompt =
          '''You are a helpful assistant that summarizes notifications concisely.

Notifications:
${notifications.take(10).join('\n')} ${notifications.length > 10 ? '\n... and ${notifications.length - 10} more' : ''}

Provide a brief, helpful summary in 1-2 sentences:''';

      final result = await _model!.generateCompletion(
        messages: [ChatMessage(content: prompt, role: 'user')],
        params: CactusCompletionParams(maxTokens: 256, temperature: 0.7),
      );

      if (result.success) {
        debugPrint(
          'Generated summary for ${notifications.length} notifications',
        );
        return result.response.trim();
      }
      return null;
    } catch (e) {
      debugPrint('Local model error: $e');
      return null;
    }
  }

  /// Dispose the model when done to free up resources
  static void dispose() {
    try {
      _model?.unload();
      _model = null;
      debugPrint('Cactus AI service disposed');
    } catch (e) {
      debugPrint('Error disposing Cactus: $e');
      _model = null;
    }
  }

  /// Check if the service is initialized and ready to use
  static bool get isInitialized => _model != null;
}

/// Recommended model configurations for low-resource devices (6GB RAM):
///
/// 1. Gemma 2B IT (Best balance)
///    - Model: gemma-2b-it-q4_0.gguf
///    - RAM: ~1.5GB
///    - Speed: Fast
///    - Quality: High
///    - Download: https://huggingface.co/google/gemma-2b-it-GGUF
///
/// 2. Qwen 1.8B (Smallest, fastest)
///    - Model: qwen1_8b-q4_0.gguf
///    - RAM: ~1GB
///    - Speed: Very fast
///    - Quality: Good
///    - Download: https://huggingface.co/Qwen/Qwen-1_8B-Chat-GGUF
///
/// 3. TinyLlama 1.1B (Ultra lightweight)
///    - Model: tinyllama-1.1b-q4_0.gguf
///    - RAM: ~700MB
///    - Speed: Extremely fast
///    - Quality: Acceptable
///    - Download: https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF
