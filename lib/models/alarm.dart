import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

class Alarm {
  const Alarm({required this.id, required this.time, required this.name});

  final String id;
  final TimeOfDay time;
  final String name;

  Map<String, dynamic> toJson() {
    return {'id': id, 'hour': time.hour, 'minute': time.minute, 'name': name};
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] ?? Uuid().v4(),
      time: TimeOfDay(hour: json['hour'] ?? 0, minute: json['minute'] ?? 0),
      name: json['name'] ?? 'New Alarm',
    );
  }

  Alarm copyWith({String? id, TimeOfDay? time, String? name}) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      name: name ?? this.name,
    );
  }
}
