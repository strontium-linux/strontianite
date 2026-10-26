import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/utils/battery_utils.dart';

class BatteryIndicator extends StatefulWidget {
  const BatteryIndicator({super.key});

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  int _batteryLevel = 100;

  late StreamSubscription<BatteryState> _subscription;

  BatteryState _batteryState = BatteryState.unknown;

  late Timer _batteryTimer;

  @override
  void initState() {
    super.initState();
    _batteryLevel = BatteryUtils.lastLevel;
    _batteryState = BatteryUtils.lastState;
    _initBattery();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        SizedBox(
          width: 24,
          height: 16,
          child: Stack(
            alignment: AlignmentGeometry.center,
            children: [
              Stack(
                alignment: AlignmentGeometry.centerLeft,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2),
                    child: FractionallySizedBox(
                      widthFactor: _batteryLevel / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getIndicatorColor(_batteryState),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildBatteryIndicator(_batteryState),
            ],
          ),
        ),
        SizedBox(
          width: 4,
          height: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    _batteryTimer.cancel();
    super.dispose();
  }

  Future<void> _initBattery() async {
    final level = await BatteryUtils.getBatteryLevel();
    BatteryUtils.cacheBatteryLevel(level);
    setState(() {
      _batteryLevel = level;
    });

    _batteryTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final level = await BatteryUtils.getBatteryLevel();
      BatteryUtils.cacheBatteryLevel(level);
      setState(() {
        _batteryLevel = level;
      });
    });

    final state = await BatteryUtils.getBatteryState();
    BatteryUtils.cacheBatteryState(state);
    setState(() {
      _batteryState = state;
    });

    _subscription = BatteryUtils.getStateStream().listen((state) {
      BatteryUtils.cacheBatteryState(state);
      setState(() {
        _batteryState = state;
      });
    });
  }

  Color _getIndicatorColor(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return Color(0xFF58ba1a);
      default:
        return Theme.of(context).colorScheme.surface;
    }
  }

  Widget _buildBatteryIndicator(BatteryState state) {
    if (state == BatteryState.charging) {
      return Icon(
        M3EIcons.electric_bolt_rounded,
        color: Theme.of(context).colorScheme.surface,
        size: 12,
      );
    } else {
      return Text(_batteryLevel.toString(), style: TextStyle(fontSize: 10));
    }
  }
}
