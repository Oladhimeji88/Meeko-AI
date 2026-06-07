import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/ai_message.dart';
import '../data/ai_provider.dart';
import '../data/ai_repository.dart';

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => AiRepository(ref.read(storageServiceProvider)),
);

class AiChatState {
  final List<AiMessage> messages;
  final bool busy;
  final String? error;

  const AiChatState({
    this.messages = const [],
    this.busy = false,
    this.error,
  });

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? busy,
    String? error,
    bool clearError = false,
  }) =>
      AiChatState(
        messages: messages ?? this.messages,
        busy: busy ?? this.busy,
        error: clearError ? null : (error ?? this.error),
      );
}

class AiController extends StateNotifier<AiChatState> {
  AiController(this._ref) : super(const AiChatState());
  final Ref _ref;

  /// Called with the assistant reply text so the UI can speak it via TTS.
  void Function(String reply)? onReply;

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.busy) return;

    final userMsg = AiMessage(role: AiRole.user, content: trimmed);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      busy: true,
      clearError: true,
    );

    final settings = _ref.read(settingsControllerProvider);
    try {
      final reply = await _ref.read(aiRepositoryProvider).send(
            type: settings.aiProvider,
            personality: settings.aiPersonality,
            history: state.messages,
          );
      state = state.copyWith(
        messages: [
          ...state.messages,
          AiMessage(role: AiRole.assistant, content: reply),
        ],
        busy: false,
      );
      // Reward interaction: pet gains a little XP per chat.
      _ref.read(settingsControllerProvider.notifier).addXp(2);
      onReply?.call(reply);
    } on AiConfigException catch (e) {
      state = state.copyWith(busy: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        busy: false,
        error: 'Something went wrong reaching the AI. Check your key/network.',
      );
    }
  }

  void clear() => state = const AiChatState();
}

final aiControllerProvider =
    StateNotifierProvider<AiController, AiChatState>((ref) => AiController(ref));
