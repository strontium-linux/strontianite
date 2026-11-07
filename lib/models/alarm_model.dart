import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.time,
    required this.name,
    required this.repeat,
  });

  final String id;
  final TimeOfDay time;
  final String name;
  final bool repeat;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'name': name,
      'repeat': repeat,
    };
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] ?? Uuid().v4(),
      time: TimeOfDay(hour: json['hour'] ?? 0, minute: json['minute'] ?? 0),
      name: json['name'] ?? 'New Alarm',
      repeat: json['repeat'] ?? true,
    );
  }

  AlarmModel copyWith({
    String? id,
    TimeOfDay? time,
    String? name,
    bool? repeat,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
      repeat: repeat ?? this.repeat,
    );
  }
}
