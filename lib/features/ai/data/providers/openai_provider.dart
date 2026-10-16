import 'package:dio/dio.dart';

import '../ai_message.dart';
import '../ai_provider.dart';

/// OpenAI Chat Completions implementation.
class OpenAiProvider implements AiProvider {
  OpenAiProvider({Dio? dio, this.model = 'gpt-4o-mini'})
      : _dio = dio ?? Dio();

  final Dio _dio;
  final String model;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  @override
  String get name => 'OpenAI';

  @override
  bool get requiresKey => true;

  @override
  Future<String> complete({
    required List<AiMessage> history,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      throw AiConfigException('Add your OpenAI API key in Settings.');
    }
    final res = await _dio.post(
      _endpoint,
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      data: {
        'model': model,
        'messages': history
            .map((m) => {'role': m.role.name, 'content': m.content})
            .toList(),
      },
    );
    return res.data['choices'][0]['message']['content'] as String;
  }
}
