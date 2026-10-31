class SettingsState {
  const SettingsState({
    required this.displayBatteryIndicator,
    required this.isHorizontal,
  });

  final bool displayBatteryIndicator;
  final bool isHorizontal;

  Map<String, dynamic> toJson() {
    return {'displayBatteryIndicator': displayBatteryIndicator};
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      displayBatteryIndicator: json['displayBatteryIndicator'] ?? true,
      isHorizontal: json['isHorizontal'] ?? false,
    );
  }

  SettingsState copyWith({bool? displayBatteryIndicator, bool? isHorizontal}) {
    return SettingsState(
      displayBatteryIndicator:
          displayBatteryIndicator ?? this.displayBatteryIndicator,
      isHorizontal: isHorizontal ?? this.isHorizontal,
    );
  }
}
