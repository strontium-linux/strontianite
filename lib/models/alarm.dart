import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

class Alarm {
  const Alarm({required this.id, required this.time, required this.name});

  final String id;
  final TimeOfDay time;
  final String name;

  Map<String, dynamic> toJson() {
    return {'time': time, 'name': name};
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] ?? Uuid().v4(),
      time: json['time'] ?? TimeOfDay.now(),
      name: json['name'] ?? 'Untitled Alarm',
    );
  }
}
