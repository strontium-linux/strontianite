import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/enums/clock_type.dart';
import 'package:strontianite/providers/settings_provider.dart';

class Clock extends ConsumerStatefulWidget {
  const Clock({super.key, required this.clockType});

  final ClockType clockType;

  @override
  ConsumerState<Clock> createState() => _ClockState();
}

class _ClockState extends ConsumerState<Clock> {
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
    final isHorizontal = ref.watch(
      settingsProvider.select((state) => state.isHorizontal),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        isHorizontal ? _buildClockHorizontal() : _buildClockVertical(),
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

  Widget _buildClockVertical() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('HH').format(_currentTime),
          style: TextStyle(
            fontFamily: _getFont(widget.clockType),
            fontSize: 112,
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
            fontSize: 112,
            height: 0.9,
            color: Theme.of(context).colorScheme.primary,
            fontVariations: [FontVariation('ROND', 100)],
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildClockHorizontal() {
    return Text(
      DateFormat('HH:mm').format(_currentTime),
      style: TextStyle(
        fontFamily: _getFont(widget.clockType),
        fontSize: 128,
        height: 0.9,
        color: Theme.of(context).colorScheme.primary,
        fontVariations: [FontVariation('ROND', 100)],
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }
}
