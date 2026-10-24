import 'package:flutter/material.dart';
import 'package:turtlinux_shell/views/alarm_editor.dart';

class AlarmsPanel extends StatefulWidget {
  const AlarmsPanel({super.key});

  @override
  State<AlarmsPanel> createState() => _AlarmsPanelState();
}

class _AlarmsPanelState extends State<AlarmsPanel> {
  final List<TimeOfDay> _alarms = [
    TimeOfDay(hour: 2, minute: 30),
    TimeOfDay(hour: 7, minute: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _alarms
            .map(
              (a) => Material(
                child: Ink(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlarmEditor(initialTime: a),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        spacing: 8,
                        children: [
                          const Icon(Icons.alarm_outlined),
                          Text(a.format(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
