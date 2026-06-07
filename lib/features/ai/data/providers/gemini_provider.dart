import 'package:dio/dio.dart';

import '../ai_message.dart';
import '../ai_provider.dart';

/// Google Gemini (generateContent) implementation.
class GeminiProvider implements AiProvider {
  GeminiProvider({Dio? dio, this.model = 'gemini-2.0-flash'})
      : _dio = dio ?? Dio();

  final Dio _dio;
  final String model;

  @override
  String get name => 'Gemini';

  @override
  bool get requiresKey => true;

  @override
  Future<String> complete({
    required List<AiMessage> history,
    String? apiKey,
  }) async {
    if (apiKey == null || apiKey.isEmpty) {
      throw AiConfigException('Add your Gemini API key in Settings.');
    }
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

    final system =
        history.where((m) => m.role == AiRole.system).map((m) => m.content).join('\n');
    final contents = history
        .where((m) => m.role != AiRole.system)
        .map((m) => {
              // Gemini uses 'model' instead of 'assistant'.
              'role': m.role == AiRole.assistant ? 'model' : 'user',
              'parts': [
                {'text': m.content}
              ],
            })
        .toList();

    final res = await _dio.post(url, data: {
      'contents': contents,
      if (system.isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': system}
          ]
        },
    });
    return res.data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
