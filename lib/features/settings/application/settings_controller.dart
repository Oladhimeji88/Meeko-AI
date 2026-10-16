import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/providers.dart';
import '../../../shared/models/app_settings.dart';

/// Holds [AppSettings] and persists every change to Hive immediately.
class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._ref) : super(_load(_ref));

  final Ref _ref;

  static AppSettings _load(Ref ref) {
    final box = ref.read(storageServiceProvider).settings;
    final raw = box.get(AppConstants.kSettings);
    if (raw is Map) return AppSettings.fromJson(raw);
    return const AppSettings();
  }

  void _persist(AppSettings next) {
    state = next;
    _ref
        .read(storageServiceProvider)
        .settings
        .put(AppConstants.kSettings, next.toJson());
  }

  void update(AppSettings Function(AppSettings) mutate) =>
      _persist(mutate(state));

  // Convenience mutators -----------------------------------------------------
  void toggle24Hour(bool v) => update((s) => s.copyWith(use24HourFormat: v));
  void toggleDarkMode(bool v) => update((s) => s.copyWith(darkMode: v));
  void setBackground(int c) => update((s) => s.copyWith(backgroundColor: c));
  void setBodyColor(int c) => update((s) => s.copyWith(bodyColor: c));
  void setEyeColor(int c) => update((s) => s.copyWith(eyeColor: c));
  void setTextColor(int c) => update((s) => s.copyWith(textColor: c));
  void setAccentColor(int c) => update((s) => s.copyWith(accentColor: c));
  void setSnooze(int m) => update((s) => s.copyWith(snoozeMinutes: m));
  void setCity(String? city) =>
      update((s) => s.copyWith(cityName: city, clearCity: city == null));
  void setWeatherEnabled(bool v) =>
      update((s) => s.copyWith(weatherEnabled: v));
  void setVoiceEnabled(bool v) => update((s) => s.copyWith(voiceEnabled: v));
  void setWakePhrase(bool v) => update((s) => s.copyWith(wakePhraseEnabled: v));
  void setPremium(bool v) => update((s) => s.copyWith(isPremium: v));

  /// Award XP and auto-level the pixel pet (every 100 XP = +1 level).
  void addXp(int amount) => update((s) {
        final xp = s.petXp + amount;
        final level = 1 + xp ~/ 100;
        return s.copyWith(petXp: xp, petLevel: level);
      });
}

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(ref),
);
