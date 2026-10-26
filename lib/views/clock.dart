import 'dart:async';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/enums/clock_type.dart';

class Clock extends StatefulWidget {
  const Clock({super.key, required this.clockType});

  final ClockType clockType;

  @override
  State<Clock> createState() => _ClockState();
}

class _ClockState extends State<Clock> {
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
    return Column(
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
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        Text(
          DateFormat('mm').format(_currentTime),
          style: TextStyle(
            fontSize: 80,
            height: 0.9,
            color: Theme.of(context).colorScheme.primary,
            fontVariations: [FontVariation('ROND', 100)],
            fontFeatures: [FontFeature.tabularFigures()],
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
