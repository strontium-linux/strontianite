class SettingsState {
  const SettingsState({
    required this.displayBatteryIndicator,
    required this.isHorizontal,
    required this.youtubeCookie,
  });

  final bool displayBatteryIndicator;
  final bool isHorizontal;
  final String youtubeCookie;

  Map<String, dynamic> toJson() {
    return {
      'displayBatteryIndicator': displayBatteryIndicator,
      'isHorizontal': isHorizontal,
      'youtubeCookie': youtubeCookie,
    };
  }

  factory SettingsState.fromJson(Map<String, dynamic> json) {
    return SettingsState(
      displayBatteryIndicator: json['displayBatteryIndicator'] ?? true,
      isHorizontal: json['isHorizontal'] ?? false,
      youtubeCookie: json['youtubeCookie'] ?? '',
    );
  }

  SettingsState copyWith({
    bool? displayBatteryIndicator,
    bool? isHorizontal,
    String? youtubeCookie,
  }) {
    return SettingsState(
      displayBatteryIndicator:
          displayBatteryIndicator ?? this.displayBatteryIndicator,
      isHorizontal: isHorizontal ?? this.isHorizontal,
      youtubeCookie: youtubeCookie ?? this.youtubeCookie,
    );
  }
}
