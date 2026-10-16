import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../services/voice_service.dart';

/// Root DI container. [storageServiceProvider] and [notificationServiceProvider]
/// are overridden in main() with already-initialized singletons so the rest of
/// the tree can read them synchronously.
final storageServiceProvider = Provider<StorageService>(
  (ref) => throw UnimplementedError('storageServiceProvider must be overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(
      'notificationServiceProvider must be overridden'),
);

final voiceServiceProvider = Provider<VoiceService>((ref) {
  final svc = VoiceService();
  ref.onDispose(svc.dispose);
  return svc;
});
