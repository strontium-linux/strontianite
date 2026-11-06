import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/settings_state_model.dart';

class _SettingsNotifier extends Notifier<SettingsStateModel> {
  @override
  SettingsStateModel build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString('global_settings');
    if (stored != null) {
      final settings = jsonDecode(stored);
      return SettingsStateModel.fromJson(settings);
    }

    return const SettingsStateModel(
      displayBatteryIndicator: true,
      isHorizontal: false,
      youtubeCookie: '',
    );
  }

  Future<void> updateBatteryPreference(bool enabled) async {
    state = state.copyWith(displayBatteryIndicator: enabled);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('global_settings', jsonEncode(state.toJson()));
  }

  Future<void> updateHorizontalPreference(bool isHorizontal) async {
    state = state.copyWith(isHorizontal: isHorizontal);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('global_settings', jsonEncode(state.toJson()));
  }

  Future<void> updateYoutubeCookie(String youtubeCookie) async {
    state = state.copyWith(youtubeCookie: youtubeCookie);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('global_settings', jsonEncode(state.toJson()));
  }
}

final settingsProvider =
    NotifierProvider<_SettingsNotifier, SettingsStateModel>(
      _SettingsNotifier.new,
    );
