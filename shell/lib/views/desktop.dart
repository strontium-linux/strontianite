import 'package:flutter/material.dart';
import 'package:turtlinux_shell/views/panel.dart';
import 'package:turtlinux_shell/views/panes/alarms_pane.dart';
import 'package:turtlinux_shell/views/panes/clock_pane.dart';
import 'package:turtlinux_shell/views/panes/media_pane.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  final List<Widget> _panels = [ClockPane(), MediaPane(), AlarmsPane()];

  int _panelIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Panel(
          switchPane: (i) {
            setState(() {
              _panelIndex = i;
            });
          },
        ),
        Expanded(
          child: Align(
            alignment: AlignmentGeometry.topCenter,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 50) {
                    debugPrint('swipe right $_panelIndex');
                    setState(() {
                      if (_panelIndex > 0) _panelIndex -= 1;
                    });
                  } else if (details.primaryVelocity! < 50) {
                    debugPrint('swipe left $_panelIndex');
                    setState(() {
                      if (_panelIndex < _panels.length - 1) _panelIndex += 1;
                    });
                  }
                }
              },
              child: _panels[_panelIndex],
            ),
          ),
        ),
      ],
    );
  }
}
