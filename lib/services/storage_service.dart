import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';

/// Thin wrapper over Hive (structured data) + flutter_secure_storage (secrets).
///
/// API keys are NEVER stored in Hive — they go in the platform keychain /
/// keystore via [secure].
class StorageService {
  late final Box settings;
  late final Box alarms;
  late final Box ai;

  final FlutterSecureStorage secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> init() async {
    await Hive.initFlutter();
    settings = await Hive.openBox(AppConstants.settingsBox);
    alarms = await Hive.openBox(AppConstants.alarmsBox);
    ai = await Hive.openBox(AppConstants.aiBox);
  }

  // ---- Secure secrets ----
  Future<void> writeSecret(String key, String value) =>
      secure.write(key: key, value: value);

  Future<String?> readSecret(String key) => secure.read(key: key);

  Future<void> deleteSecret(String key) => secure.delete(key: key);
}
