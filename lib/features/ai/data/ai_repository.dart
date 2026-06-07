import '../../../core/constants/app_constants.dart';
import '../../../core/enums.dart';
import '../../../services/storage_service.dart';
import 'ai_message.dart';
import 'ai_provider.dart';
import 'providers/claude_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/local_provider.dart';
import 'providers/openai_provider.dart';

/// Resolves the active [AiProvider] from settings, injects the secure API key,
/// and exposes a single [send] entry point to the controller.
class AiRepository {
  AiRepository(this._storage);
  final StorageService _storage;

  AiProvider providerFor(AiProviderType type) => switch (type) {
        AiProviderType.openai => OpenAiProvider(),
        AiProviderType.claude => ClaudeProvider(),
        AiProviderType.gemini => GeminiProvider(),
        AiProviderType.local => LocalProvider(),
      };

  Future<String?> _keyFor(AiProviderType type) => switch (type) {
        AiProviderType.openai => _storage.readSecret(AppConstants.kOpenAiKey),
        AiProviderType.claude => _storage.readSecret(AppConstants.kClaudeKey),
        AiProviderType.gemini => _storage.readSecret(AppConstants.kGeminiKey),
        AiProviderType.local => Future.value(null),
      };

  /// Build the message list (system prompt + history) and dispatch.
  Future<String> send({
    required AiProviderType type,
    required AiPersonality personality,
    required List<AiMessage> history,
  }) async {
    final provider = providerFor(type);
    final key = await _keyFor(type);

    final messages = <AiMessage>[
      AiMessage(role: AiRole.system, content: personality.systemPrompt),
      ...history,
    ];
    return provider.complete(history: messages, apiKey: key);
  }
}
