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
            fontFamily: _getFont(widget.clockType),
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
            fontFamily: _getFont(widget.clockType),
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

  String _getFont(ClockType clockType) {
    switch (clockType) {
      case ClockType.flex:
        return 'Google Sans Flex';
      case ClockType.frameWeathervf:
        return 'Frame WeatherVF';
      case ClockType.growth:
        return 'Growth';
      case ClockType.inflatevf:
        return 'InflateVF';
      case ClockType.rotationgx:
        return 'RotationGX';
      case ClockType.rubyRegular:
        return 'Ruby Regu;ar';
    }
  }
}
