import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/models/alarm.dart';

class AlarmEditor extends StatefulWidget {
  const AlarmEditor({super.key, required this.alarm});

  final Alarm alarm;

  @override
  State<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends State<AlarmEditor> {
  late TimeOfDay _time = widget.alarm.time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit alarm'),
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
