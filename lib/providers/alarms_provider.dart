import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strontianite/handlers/alarms_handler.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/alarm_model.dart';

class _AlarmsNotifier extends Notifier<List<AlarmModel>> {
  @override
  List<AlarmModel> build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final json = prefs.getStringList('alarms');

    if (json != null) {
      return json.map((i) {
        final map = jsonDecode(i);
        return AlarmModel.fromJson(map);
      }).toList();
    }

    return List.empty();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await AlarmsHandler.registerAlarm(alarm);

    final found = state.indexWhere((a) => a.id == alarm.id);
    if (found != -1) {
      state = [...state.sublist(0, found), alarm, ...state.sublist(found + 1)];
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
    state = List<AlarmModel>.from(state)..removeAt(found);
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

  AlarmModel getAlarm(String id) {
    return state.firstWhere((a) => a.id == id);
  }
}

final alarmsProvider = NotifierProvider<_AlarmsNotifier, List<AlarmModel>>(
  _AlarmsNotifier.new,
);
