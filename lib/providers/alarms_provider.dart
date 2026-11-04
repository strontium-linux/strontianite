import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strontianite/handlers/alarms_handler.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/alarm.dart';

class _AlarmsNotifier extends Notifier<List<Alarm>> {
  @override
  List<Alarm> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = prefs.getStringList('alarms');

    if (json != null) {
      return json.map((i) {
        final map = jsonDecode(i);
        return Alarm.fromJson(map);
      }).toList();
    }

    return List.empty();
  }

  Future<void> updateAlarm(Alarm alarm) async {
    await AlarmsHandler.registerAlarm(alarm);

    final found = state.indexWhere((a) => a.id == alarm.id);
    if (found != -1) {
      state[found] = alarm;
    } else {
      state = [...state, alarm];
    }

    await ref
        .read(sharedPreferencesProvider)
        .setStringList(
          'alarms',
          state.map((a) {
            final map = a.toJson();
            return jsonEncode(map);
          }).toList(),
        );
  }

  Future<void> deleteAlarm(String id) async {
    final found = state.indexWhere((a) => a.id == id);
    await AlarmsHandler.unregisterAlarm(id);
    state = List<Alarm>.from(state)..removeAt(found);
    await ref
        .read(sharedPreferencesProvider)
        .setStringList(
          'alarms',
          state.map((a) {
            final map = a.toJson();
            return jsonEncode(map);
          }).toList(),
        );
  }

  Alarm getAlarm(String id) {
    return state.firstWhere((a) => a.id == id);
  }
}

final alarmsProvider = NotifierProvider<_AlarmsNotifier, List<Alarm>>(
  _AlarmsNotifier.new,
);
