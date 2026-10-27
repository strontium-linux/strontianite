import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/settings_state.dart';

class _SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString('global_settings');
    if (stored != null) {
      final settings = jsonDecode(stored);
      return SettingsState.fromJson(settings);
    }

    return const SettingsState(displayBatteryIndicator: true);
  }

  Future<void> updateBatteryPreference(bool enabled) async {
    state = state.copyWith(displayBatteryIndicator: enabled);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('global_settings', jsonEncode(state.toJson()));
  }
}

final settingsProvider = NotifierProvider<_SettingsNotifier, SettingsState>(
  _SettingsNotifier.new,
);
