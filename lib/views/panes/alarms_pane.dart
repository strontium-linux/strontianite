import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/views/alarm_editor.dart';

class AlarmsPane extends StatefulWidget {
  const AlarmsPane({super.key});

  @override
  State<AlarmsPane> createState() => _AlarmsPaneState();
}

class _AlarmsPaneState extends State<AlarmsPane> {
  final List<TimeOfDay> _alarms = [
    TimeOfDay(hour: 2, minute: 30),
    TimeOfDay(hour: 7, minute: 15),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: _alarms
              .map(
                (a) => Material(
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                        padding: EdgeInsets.all(16),
                        child: Row(
                          spacing: 8,
                          children: [
                            const Icon(M3EIcons.alarm_rounded),
                            Text(
                              a.format(context),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
