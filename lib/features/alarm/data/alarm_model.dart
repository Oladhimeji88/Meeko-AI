import '../../../core/enums.dart';

/// A single alarm. Persisted as JSON in Hive.
class AlarmModel {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool enabled;
  final AlarmRepeat repeat;

  /// For [AlarmRepeat.custom]: weekdays as DateTime.monday..sunday (1..7).
  final List<int> customDays;
  final bool vibrate;
  final String soundAsset;

  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = 'Alarm',
    this.enabled = true,
    this.repeat = AlarmRepeat.once,
    this.customDays = const [],
    this.vibrate = true,
    this.soundAsset = 'sounds/alarm.mp3',
  });

  /// Distinct weekdays this alarm should fire on (empty => one-shot).
  List<int> get activeWeekdays {
    switch (repeat) {
      case AlarmRepeat.daily:
        return const [1, 2, 3, 4, 5, 6, 7];
      case AlarmRepeat.weekdays:
        return const [1, 2, 3, 4, 5];
      case AlarmRepeat.weekends:
        return const [6, 7];
      case AlarmRepeat.custom:
        return customDays;
      case AlarmRepeat.once:
        return const [];
    }
  }

  String get timeLabel {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Stable integer notification id derived from the uuid.
  int get notificationId => id.hashCode & 0x7fffffff;

  AlarmModel copyWith({
    int? hour,
    int? minute,
    String? label,
    bool? enabled,
    AlarmRepeat? repeat,
    List<int>? customDays,
    bool? vibrate,
    String? soundAsset,
  }) =>
      AlarmModel(
        id: id,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        label: label ?? this.label,
        enabled: enabled ?? this.enabled,
        repeat: repeat ?? this.repeat,
        customDays: customDays ?? this.customDays,
        vibrate: vibrate ?? this.vibrate,
        soundAsset: soundAsset ?? this.soundAsset,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'enabled': enabled,
        'repeat': repeat.name,
        'customDays': customDays,
        'vibrate': vibrate,
        'soundAsset': soundAsset,
      };

  factory AlarmModel.fromJson(Map<dynamic, dynamic> json) => AlarmModel(
        id: json['id'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        label: (json['label'] as String?) ?? 'Alarm',
        enabled: (json['enabled'] as bool?) ?? true,
        repeat: AlarmRepeat.values.firstWhere(
          (e) => e.name == json['repeat'],
          orElse: () => AlarmRepeat.once,
        ),
        customDays:
            (json['customDays'] as List?)?.map((e) => e as int).toList() ??
                const [],
        vibrate: (json['vibrate'] as bool?) ?? true,
        soundAsset: (json['soundAsset'] as String?) ?? 'sounds/alarm.mp3',
      );
}
