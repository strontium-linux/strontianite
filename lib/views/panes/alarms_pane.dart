import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/models/alarm.dart';
import 'package:strontianite/providers/alarms_provider.dart';
import 'package:strontianite/views/alarm_editor.dart';

class AlarmsPane extends ConsumerStatefulWidget {
  const AlarmsPane({super.key});

  @override
  ConsumerState<AlarmsPane> createState() => _AlarmsPaneState();
}

class _AlarmsPaneState extends ConsumerState<AlarmsPane> {
  @override
  Widget build(BuildContext context) {
    final List<Alarm> alarms = ref.watch(alarmsProvider);

    return Align(
      alignment: AlignmentGeometry.topCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: alarms
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
                            builder: (context) => AlarmEditor(alarm: a),
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
                              a.time.format(context),
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
