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
}

final alarmsProvider = NotifierProvider<_AlarmsNotifier, List<Alarm>>(
  _AlarmsNotifier.new,
);
