import '../../../services/storage_service.dart';
import 'alarm_model.dart';

/// CRUD persistence for alarms backed by the Hive alarms box.
class AlarmRepository {
  AlarmRepository(this._storage);
  final StorageService _storage;

  List<AlarmModel> all() {
    return _storage.alarms.values
        .whereType<Map>()
        .map(AlarmModel.fromJson)
        .toList()
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  }

  Future<void> save(AlarmModel alarm) =>
      _storage.alarms.put(alarm.id, alarm.toJson());

  Future<void> delete(String id) => _storage.alarms.delete(id);
}
