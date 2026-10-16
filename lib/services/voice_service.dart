import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../core/enums.dart';

/// Wraps Text-to-Speech (output) and Speech-to-Text (input) for PixelBuddy AI.
///
/// Personality tunes pitch/rate so the buddy "sounds" different per mode.
class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final SpeechToText _stt = SpeechToText();

  bool _ttsReady = false;
  bool _sttAvailable = false;

  /// Called repeatedly with `true` while speaking, `false` when idle —
  /// drives the buddy's talking mouth animation.
  void Function(bool speaking)? onSpeakingChanged;

  Future<void> _ensureTts(AiPersonality personality) async {
    if (!_ttsReady) {
      await _tts.awaitSpeakCompletion(true);
      _tts.setStartHandler(() => onSpeakingChanged?.call(true));
      _tts.setCompletionHandler(() => onSpeakingChanged?.call(false));
      _tts.setCancelHandler(() => onSpeakingChanged?.call(false));
      _ttsReady = true;
    }
    // Personality voice tuning.
    final (rate, pitch) = switch (personality) {
      AiPersonality.friendly => (0.5, 1.0),
      AiPersonality.motivator => (0.55, 1.15),
      AiPersonality.chill => (0.42, 0.9),
      AiPersonality.retroGamer => (0.5, 1.25),
    };
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
  }

  Future<void> speak(String text,
      {AiPersonality personality = AiPersonality.friendly}) async {
    await _ensureTts(personality);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    onSpeakingChanged?.call(false);
  }

  Future<bool> initStt() async {
    _sttAvailable = await _stt.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    return _sttAvailable;
  }

  /// Begin listening; [onResult] fires with the final recognized phrase.
  Future<void> listen(void Function(String text) onResult) async {
    if (!_sttAvailable) await initStt();
    if (!_sttAvailable) return;
    await _stt.listen(
      onResult: (r) {
        if (r.finalResult) onResult(r.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  bool get isListening => _stt.isListening;

  Future<void> stopListening() => _stt.stop();

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}
