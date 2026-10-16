import 'dart:math';

import 'package:intl/intl.dart';

import '../ai_message.dart';
import '../ai_provider.dart';

/// Offline, rule-based companion. Requires no API key so PixelBuddy AI works
/// out of the box. For real conversational ability, point the architecture at
/// a local LLM server (e.g. Ollama) by extending [complete].
class LocalProvider implements AiProvider {
  LocalProvider({this.endpoint});

  /// Optional local LLM HTTP endpoint (e.g. http://localhost:11434). If set,
  /// you can extend this class to call it; by default we use canned logic.
  final String? endpoint;

  final _rng = Random();

  static const _jokes = [
    'Why did the pixel cross the screen? To get to the other sprite! 🎮',
    'I told my CPU a joke… it didn’t process it. 🤖',
    'Why was the clock in detention? It kept tocking back! ⏰',
    'There are 10 types of people: those who get binary and those who don’t.',
  ];

  static const _productivity = [
    'Try the Pomodoro: 25 min focus, 5 min break. Want me to start a timer?',
    'Pick ONE task. Smallest next step. Go. You’ve got this! 💪',
    'Tidy desk, tidy mind. 2-minute reset, then dive in.',
  ];

  @override
  String get name => 'PixelBuddy (Local)';

  @override
  bool get requiresKey => false;

  @override
  Future<String> complete({
    required List<AiMessage> history,
    String? apiKey,
  }) async {
    final last = history.lastWhere(
      (m) => m.role == AiRole.user,
      orElse: () => AiMessage(role: AiRole.user, content: ''),
    );
    final q = last.content.toLowerCase();
    await Future.delayed(const Duration(milliseconds: 350)); // feels alive

    if (q.contains('joke') || q.contains('funny')) {
      return _jokes[_rng.nextInt(_jokes.length)];
    }
    if (q.contains('time')) {
      return 'It is ${DateFormat('h:mm a').format(DateTime.now())}. ⏰';
    }
    if (q.contains('date') || q.contains('day')) {
      return 'Today is ${DateFormat('EEEE, MMMM d').format(DateTime.now())}.';
    }
    if (q.contains('weather')) {
      return 'Open the clock tab for live weather — I react to it with my face! '
          'For full forecasts, add a weather API key in Settings.';
    }
    if (q.contains('alarm')) {
      return 'Head to the Alarms tab to add, edit, or repeat alarms. '
          'I’ll wake you with my surprised face! 😲';
    }
    if (q.contains('timer') || q.contains('pomodoro')) {
      return 'Use the Timer tab — I’ve got 5/10/25-min and 1-hour presets ready.';
    }
    if (q.contains('advice') || q.contains('focus') || q.contains('productive')) {
      return _productivity[_rng.nextInt(_productivity.length)];
    }
    if (q.contains('hello') || q.contains('hi') || q.contains('hey')) {
      return 'Hey there! I’m PixelBuddy. Ask me for a joke, the time, '
          'or some productivity tips! 🎮';
    }
    if (q.isEmpty) {
      return 'I’m listening! Try “tell me a joke” or “give me focus advice”.';
    }
    return 'I’m the offline PixelBuddy, so I keep it simple. Add an OpenAI, '
        'Claude, or Gemini key in Settings to unlock full conversations! '
        'Meanwhile: ${_productivity[_rng.nextInt(_productivity.length)]}';
  }
}
