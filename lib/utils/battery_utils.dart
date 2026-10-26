import 'package:battery_plus/battery_plus.dart';

class BatteryUtils {
  static final battery = Battery();
  static int lastLevel = 100;
  static BatteryState lastState = BatteryState.unknown;

  static Future<int> getBatteryLevel() async {
    final level = await battery.batteryLevel;
    return level <= 100 && level >= 0 ? level : 100;
  }

  static Future<BatteryState> getBatteryState() async {
    return await battery.batteryState;
  }

  static Stream<BatteryState> getStateStream() {
    return battery.onBatteryStateChanged;
  }

  static void cacheBatteryLevel(int level) {
    lastLevel = level;
  }

  static void cacheBatteryState(BatteryState state) {
    lastState = state;
  }
}
