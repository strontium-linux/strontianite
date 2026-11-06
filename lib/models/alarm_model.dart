import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

class AlarmModel {
  const AlarmModel({required this.id, required this.time, required this.name});

  final String id;
  final TimeOfDay time;
  final String name;

  Map<String, dynamic> toJson() {
    return {'id': id, 'hour': time.hour, 'minute': time.minute, 'name': name};
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] ?? Uuid().v4(),
      time: TimeOfDay(hour: json['hour'] ?? 0, minute: json['minute'] ?? 0),
      name: json['name'] ?? 'New Alarm',
    );
  }

  AlarmModel copyWith({String? id, TimeOfDay? time, String? name}) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
    );
  }
}
