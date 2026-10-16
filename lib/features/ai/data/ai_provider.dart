import 'ai_message.dart';

/// Abstraction every LLM back-end implements. Swapping providers is a matter of
/// returning a different concrete implementation from the factory — the rest of
/// the app only depends on this interface (Strategy + Repository pattern).
abstract class AiProvider {
  /// Human-readable name, e.g. "OpenAI".
  String get name;

  /// Whether this provider needs an API key to function.
  bool get requiresKey;

  /// Send the [history] (including the system prompt) and return the assistant
  /// reply. [apiKey] may be null for providers that don't need one.
  Future<String> complete({
    required List<AiMessage> history,
    String? apiKey,
  });
}

/// Thrown when a provider is misconfigured (e.g. missing key) so the UI can
/// prompt the user instead of crashing.
class AiConfigException implements Exception {
  final String message;
  AiConfigException(this.message);
  @override
  String toString() => message;
}
