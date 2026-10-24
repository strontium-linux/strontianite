import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockPane extends StatefulWidget {
  const ClockPane({super.key});

  @override
  State<ClockPane> createState() => _ClockPaneState();
}

class _ClockPaneState extends State<ClockPane> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
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
        child: Center(
          child: Text(
            _currentTime,
            style: TextStyle(
              fontSize: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
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
    final String time = DateFormat('hh:mm:ss a').format(now);
    setState(() {
      _currentTime = time;
    });
  }
}
