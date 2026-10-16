import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize singletons before the app reads them.
  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();
  // Fire-and-forget permission prompts (safe if already granted).
  notifications.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const PixelBuddyApp(),
    ),
  );
}
