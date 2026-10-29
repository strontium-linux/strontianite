import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/models/alarm.dart';
import 'package:strontianite/providers/alarms_provider.dart';

class AlarmEditor extends ConsumerStatefulWidget {
  const AlarmEditor({super.key, required this.alarm, this.newAlarm = false});

  final Alarm alarm;
  final bool newAlarm;

  @override
  ConsumerState<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends ConsumerState<AlarmEditor> {
  late TimeOfDay _time = widget.alarm.time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newAlarm ? 'Create alarm' : 'Edit alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              spacing: 16,
              children: [
                Text(_time.format(context)),
                M3EIconButton(
                  onPressed: () => _selectTime(),
                  icon: const Icon(M3EIcons.schedule_rounded),
                  tooltip: 'Change time',
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ref.read(alarmsProvider.notifier).updateAlarm(widget.alarm);
        },
        child: const Icon(M3EIcons.check_rounded),
      ),
    );
  }

  void _selectTime() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (timeOfDay != null) {
      setState(() {
        _time = timeOfDay;
      });
    }
  }
}
