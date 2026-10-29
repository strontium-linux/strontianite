import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

final alarmsProvider = NotifierProvider<_AlarmsNotifier, List<Alarm>>(
  _AlarmsNotifier.new,
);
