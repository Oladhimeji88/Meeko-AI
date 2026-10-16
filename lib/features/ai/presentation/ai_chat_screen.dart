import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/enums.dart';
import '../../clock/presentation/widgets/pixel_buddy.dart';
import '../../settings/application/settings_controller.dart';
import '../application/ai_controller.dart';
import '../data/ai_message.dart';

/// PixelBuddy AI chat: text + voice, with a live talking buddy and a
/// personality selector.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _speaking = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    final voice = ref.read(voiceServiceProvider);
    voice.onSpeakingChanged = (s) {
      if (mounted) setState(() => _speaking = s);
    };
    ref.read(aiControllerProvider.notifier).onReply = (reply) {
      final settings = ref.read(settingsControllerProvider);
      if (settings.voiceEnabled) {
        voice.speak(reply, personality: settings.aiPersonality);
      }
      _scrollToBottom();
    };
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? text]) async {
    final msg = text ?? _input.text;
    _input.clear();
    await ref.read(aiControllerProvider.notifier).send(msg);
    _scrollToBottom();
  }

  Future<void> _toggleMic() async {
    final voice = ref.read(voiceServiceProvider);
    if (_listening) {
      await voice.stopListening();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await voice.listen((text) {
      setState(() => _listening = false);
      if (text.trim().isNotEmpty) _send(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsControllerProvider);
    final chat = ref.watch(aiControllerProvider);
    final mood = _speaking
        ? BuddyMood.talking
        : (_listening ? BuddyMood.surprised : BuddyMood.happy);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PixelBuddy AI'),
        actions: [
          PopupMenuButton<AiPersonality>(
            icon: const Icon(Icons.face_retouching_natural),
            initialValue: s.aiPersonality,
            onSelected: (p) =>
                ref.read(settingsControllerProvider.notifier).update(
                      (st) => st.copyWith(aiPersonality: p),
                    ),
            itemBuilder: (_) => [
              for (final p in AiPersonality.values)
                PopupMenuItem(value: p, child: Text(p.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                PixelBuddy(
                  mood: mood,
                  body: s.body,
                  eye: s.eye,
                  accent: s.accent,
                  size: 120,
                  speaking: _speaking,
                ),
                Text('Mode: ${s.aiPersonality.label}',
                    style: TextStyle(color: s.text.withValues(alpha: 0.6))),
              ],
            ),
          ),
          if (chat.error != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.errorContainer,
              padding: const EdgeInsets.all(8),
              child: Text(chat.error!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer)),
            ),
          Expanded(
            child: chat.messages.isEmpty
                ? const Center(
                    child: Text('Say hi to PixelBuddy! 👋\nTry “tell me a joke”.',
                        textAlign: TextAlign.center))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) => _Bubble(
                        message: chat.messages[i], accent: s.accent, body: s.body),
                  ),
          ),
          if (chat.busy) const LinearProgressIndicator(),
          _Composer(
            controller: _input,
            listening: _listening,
            onSend: _send,
            onMic: _toggleMic,
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(
      {required this.message, required this.accent, required this.body});
  final AiMessage message;
  final Color accent;
  final Color body;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? accent : body.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(message.content,
            style: TextStyle(
                fontSize: 18,
                color: isUser ? Colors.black : Colors.white)),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.listening,
    required this.onSend,
    required this.onMic,
  });
  final TextEditingController controller;
  final bool listening;
  final void Function([String?]) onSend;
  final VoidCallback onMic;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            IconButton.filledTonal(
              icon: Icon(listening ? Icons.mic : Icons.mic_none),
              color: listening ? Colors.red : null,
              onPressed: onMic,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (v) => onSend(v),
                decoration: const InputDecoration(
                  hintText: 'Message PixelBuddy…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton.filled(
              icon: const Icon(Icons.send),
              onPressed: () => onSend(),
            ),
          ],
        ),
      ),
    );
  }
}
