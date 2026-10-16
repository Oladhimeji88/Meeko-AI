import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../core/enums.dart';
import '../../../core/theme/app_theme.dart';
import '../application/settings_controller.dart';

/// All user customization: clock format, theme colors, weather, AI provider +
/// keys, voice, snooze, and premium status.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsControllerProvider);
    final c = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _section('Pet'),
          ListTile(
            leading: const Icon(Icons.pets),
            title: Text('PixelBuddy · Level ${s.petLevel}'),
            subtitle: LinearProgressIndicator(value: (s.petXp % 100) / 100),
            trailing: Text('${s.petXp} XP'),
          ),

          _section('Clock'),
          SwitchListTile(
            title: const Text('24-hour format'),
            value: s.use24HourFormat,
            onChanged: c.toggle24Hour,
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: s.darkMode,
            onChanged: c.toggleDarkMode,
          ),

          _section('Theme colors'),
          _ColorTile(
            label: 'Background',
            color: s.background,
            presets: AppTheme.presetBackgrounds,
            onPick: c.setBackground,
          ),
          _ColorTile(label: 'Character body', color: s.body, onPick: c.setBodyColor),
          _ColorTile(label: 'Eyes', color: s.eye, onPick: c.setEyeColor),
          _ColorTile(label: 'Clock text', color: s.text, onPick: c.setTextColor),
          _ColorTile(label: 'Accent', color: s.accent, onPick: c.setAccentColor),

          _section('Weather'),
          SwitchListTile(
            title: const Text('Enable weather'),
            value: s.weatherEnabled,
            onChanged: c.setWeatherEnabled,
          ),
          ListTile(
            title: const Text('City'),
            subtitle: Text(s.cityName ?? 'Use device location'),
            trailing: const Icon(Icons.edit),
            onTap: () => _editCity(context, ref, s.cityName),
          ),
          _SecretTile(
            label: 'Weather API key (OpenWeatherMap)',
            secretKey: AppConstants.kWeatherKey,
          ),

          _section('AI Companion'),
          ListTile(
            title: const Text('Provider'),
            trailing: DropdownButton<AiProviderType>(
              value: s.aiProvider,
              onChanged: (v) => v == null
                  ? null
                  : c.update((st) => st.copyWith(aiProvider: v)),
              items: const [
                DropdownMenuItem(
                    value: AiProviderType.local, child: Text('Local (offline)')),
                DropdownMenuItem(
                    value: AiProviderType.openai, child: Text('OpenAI')),
                DropdownMenuItem(
                    value: AiProviderType.claude, child: Text('Claude')),
                DropdownMenuItem(
                    value: AiProviderType.gemini, child: Text('Gemini')),
              ],
            ),
          ),
          ListTile(
            title: const Text('Personality'),
            trailing: DropdownButton<AiPersonality>(
              value: s.aiPersonality,
              onChanged: (v) => v == null
                  ? null
                  : c.update((st) => st.copyWith(aiPersonality: v)),
              items: [
                for (final p in AiPersonality.values)
                  DropdownMenuItem(value: p, child: Text(p.label)),
              ],
            ),
          ),
          const _SecretTile(
              label: 'OpenAI API key', secretKey: AppConstants.kOpenAiKey),
          const _SecretTile(
              label: 'Claude API key', secretKey: AppConstants.kClaudeKey),
          const _SecretTile(
              label: 'Gemini API key', secretKey: AppConstants.kGeminiKey),
          SwitchListTile(
            title: const Text('Voice replies (TTS)'),
            value: s.voiceEnabled,
            onChanged: c.setVoiceEnabled,
          ),
          SwitchListTile(
            title: const Text('Wake phrase “Hey PixelBuddy”'),
            subtitle: const Text('Premium · always-listening hotword'),
            value: s.wakePhraseEnabled,
            onChanged: s.isPremium ? c.setWakePhrase : null,
          ),

          _section('Alarms'),
          ListTile(
            title: const Text('Snooze duration'),
            trailing: DropdownButton<int>(
              value: s.snoozeMinutes,
              onChanged: (v) => v == null ? null : c.setSnooze(v),
              items: const [3, 5, 10, 15]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
                  .toList(),
            ),
          ),

          _section('Premium'),
          SwitchListTile(
            secondary: const Icon(Icons.workspace_premium),
            title: const Text('Premium (demo unlock)'),
            subtitle: const Text(
                'Unlocks extra personalities, voice packs, custom avatars, '
                'unlimited themes. Payment gateway not wired yet.'),
            value: s.isPremium,
            onChanged: c.setPremium,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(fontSize: 18, letterSpacing: 1)),
      );

  Future<void> _editCity(
      BuildContext context, WidgetRef ref, String? current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('City'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
              hintText: 'e.g. London — leave blank for GPS'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Use GPS')),
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    final city = (result == null || result.isEmpty) ? null : result;
    ref.read(settingsControllerProvider.notifier).setCity(city);
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile({
    required this.label,
    required this.color,
    required this.onPick,
    this.presets = const [],
  });
  final String label;
  final Color color;
  final ValueChanged<int> onPick;
  final List<int> presets;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: presets.isEmpty
          ? null
          : Wrap(
              spacing: 6,
              children: [
                for (final p in presets)
                  GestureDetector(
                    onTap: () => onPick(p),
                    child: Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: Color(p),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                  ),
              ],
            ),
      trailing: GestureDetector(
        onTap: () => _openPicker(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white30),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    var picked = color;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(label),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: color,
            enableAlpha: false,
            onColorChanged: (c) => picked = c,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              onPick(picked.toARGB32());
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

/// Securely captures an API key into flutter_secure_storage (never Hive).
class _SecretTile extends ConsumerStatefulWidget {
  const _SecretTile({required this.label, required this.secretKey});
  final String label;
  final String secretKey;

  @override
  ConsumerState<_SecretTile> createState() => _SecretTileState();
}

class _SecretTileState extends ConsumerState<_SecretTile> {
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final v = await ref
        .read(storageServiceProvider)
        .readSecret(widget.secretKey);
    if (mounted) setState(() => _hasKey = v != null && v.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.label),
      subtitle: Text(_hasKey ? '•••••• saved' : 'Not set'),
      trailing: Icon(_hasKey ? Icons.check_circle : Icons.key,
          color: _hasKey ? Colors.green : null),
      onTap: _edit,
    );
  }

  Future<void> _edit() async {
    final ctrl = TextEditingController();
    final storage = ref.read(storageServiceProvider);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.label),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Paste key…'),
        ),
        actions: [
          if (_hasKey)
            TextButton(
              onPressed: () => Navigator.pop(context, ''),
              child: const Text('Remove'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (result.isEmpty) {
      await storage.deleteSecret(widget.secretKey);
    } else {
      await storage.writeSecret(widget.secretKey, result);
    }
    _check();
  }
}
