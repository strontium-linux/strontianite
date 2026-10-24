import 'package:flutter/material.dart';
import 'package:turtlinux_shell/views/panel.dart';
import 'package:turtlinux_shell/views/panels/clock_panel.dart';

class Desktop extends StatefulWidget {
  const Desktop({super.key});

  @override
  State<Desktop> createState() => _DesktopState();
}

class _DesktopState extends State<Desktop> {
  final List<Widget> panels = [ClockPanel()];

  int _panelIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Panel(),
        Expanded(child: panels[_panelIndex]),
      ],
    );
  }
}
