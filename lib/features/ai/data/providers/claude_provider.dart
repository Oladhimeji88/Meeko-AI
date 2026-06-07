import 'package:dio/dio.dart';

import '../ai_message.dart';
import '../ai_provider.dart';

/// Anthropic Claude (Messages API) implementation.
///
/// Claude separates the system prompt from the message list, so we extract any
/// system message and pass it via the `system` field.
class ClaudeProvider implements AiProvider {
  ClaudeProvider({Dio? dio, this.model = 'claude-sonnet-4-6'})
      : _dio = dio ?? Dio();

  final Dio _dio;
  final String model;

  static const _endpoint = 'https://api.anthropic.com/v1/messages';

  @override
  String get name => 'Claude';

  @override
  bool get requiresKey => true;

  @override
  Future<String> complete({
    required List<AiMessage> history,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      throw AiConfigException('Add your Claude API key in Settings.');
    }
    final system = history
        .where((m) => m.role == AiRole.system)
        .map((m) => m.content)
        .join('\n');
    final messages = history
        .where((m) => m.role != AiRole.system)
        .map((m) => {'role': m.role.name, 'content': m.content})
        .toList();

    final res = await _dio.post(
      _endpoint,
      options: Options(headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      }),
      data: {
        'model': model,
        'max_tokens': 512,
        if (system.isNotEmpty) 'system': system,
        'messages': messages,
      },
    );
    return res.data['content'][0]['text'] as String;
  }
}
