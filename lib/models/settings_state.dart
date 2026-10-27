class SettingsState {
  const SettingsState({required this.displayBatteryIndicator});

  final bool displayBatteryIndicator;

  Map<String, dynamic> toJson() {
    return {'displayBatteryIndicator': displayBatteryIndicator};
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      displayBatteryIndicator: json['displayBatteryIndicator'] ?? true,
    );
  }

  SettingsState copyWith({bool? displayBatteryIndicator}) {
    return SettingsState(
      displayBatteryIndicator:
          displayBatteryIndicator ?? this.displayBatteryIndicator,
    );
  }
}
