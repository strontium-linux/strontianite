import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:turtlinux_shell/views/battery_indicator.dart';

class ClockPane extends StatefulWidget {
  const ClockPane({super.key});

  @override
  State<ClockPane> createState() => _ClockPaneState();
}

class _ClockPaneState extends State<ClockPane> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        debugPrint('long press detected');
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: AlignmentGeometry.centerRight,
                child: SizedBox(
                  width: 32,
                  height: 16,
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [const BatteryIndicator()],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('HH').format(_currentTime),
                    style: TextStyle(
                      fontSize: 80,
                      height: 0.9,
                      color: Theme.of(context).colorScheme.primary,
                      fontVariations: [FontVariation('ROND', 100)],
                    ),
                  ),
                  Text(
                    DateFormat('mm').format(_currentTime),
                    style: TextStyle(
                      fontSize: 80,
                      height: 0.9,
                      color: Theme.of(context).colorScheme.primary,
                      fontVariations: [FontVariation('ROND', 100)],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEEE, MMMM d').format(_currentTime),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontVariations: [FontVariation('ROND', 100)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _currentTime = now;
    });
  }
}
