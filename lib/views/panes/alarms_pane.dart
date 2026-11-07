import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/models/alarm_model.dart';
import 'package:strontianite/providers/alarms_provider.dart';
import 'package:strontianite/views/alarm_editor.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

class AlarmsPane extends ConsumerStatefulWidget {
  const AlarmsPane({super.key});

  @override
  ConsumerState<AlarmsPane> createState() => _AlarmsPaneState();
}

const _uuid = Uuid();

class _AlarmsPaneState extends ConsumerState<AlarmsPane> {
  @override
  Widget build(BuildContext context) {
    final List<AlarmModel> alarms = ref.watch(alarmsProvider);

    return Stack(
      children: [
        alarms.isEmpty
            ? Positioned.fill(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 16,
                  children: [
                    const Icon(M3EIcons.alarm_rounded),
                    const Text('No alarms yet'),
                  ],
                ),
              )
            : Align(
                alignment: AlignmentGeometry.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: alarms
                        .sorted(
                          (a, b) => _timeTillNow(
                            a.time,
                          ).compareTo(_timeTillNow(b.time)),
                        )
                        .map(
                          (a) => Dismissible(
                            key: Key(a.id),
                            onDismissed: (direction) {
                              ref
                                  .read(alarmsProvider.notifier)
                                  .deleteAlarm(a.id);
                            },
                            child: Material(
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AlarmEditor(alarm: a),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: Row(
                                      spacing: 16,
                                      children: [
                                        a.repeat
                                            ? const Icon(
                                                M3EIcons.repeat_rounded,
                                              )
                                            : const Icon(
                                                M3EIcons.alarm_rounded,
                                              ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(a.name),
                                            Text(
                                              a.time.format(context),
                                              style: TextStyle(fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmEditor(
                    alarm: AlarmModel(
                      id: _uuid.v4(),
                      time: TimeOfDay.now(),
                      name: 'New Alarm',
                      repeat: true,
                    ),
                    newAlarm: true,
                  ),
                ),
              );
            },
            child: const Icon(M3EIcons.add_rounded),
          ),
        ),
      ],
    );
  }

  int _timeTillNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final diff = (time.hour * 60 + time.minute - nowMinutes).abs();
    return diff > 720 ? 1440 - diff : diff;
  }
}
