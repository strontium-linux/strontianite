import 'package:battery_plus/battery_plus.dart';

class BatteryUtils {
  static final battery = Battery();
  static int lastLevel = 100;
  static BatteryState lastState = BatteryState.unknown;

  static Future<int> getBatteryLevel() async {
    return await battery.batteryLevel;
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
