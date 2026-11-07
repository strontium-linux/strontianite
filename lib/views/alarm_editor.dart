import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:strontianite/models/alarm_model.dart';
import 'package:strontianite/providers/alarms_provider.dart';

class AlarmEditor extends ConsumerStatefulWidget {
  const AlarmEditor({super.key, required this.alarm, this.newAlarm = false});

  final AlarmModel alarm;
  final bool newAlarm;

  @override
  ConsumerState<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends ConsumerState<AlarmEditor> {
  late TimeOfDay _time = widget.alarm.time;
  late String _name = widget.alarm.name;
  final TextEditingController _nameController = TextEditingController();
  late bool _repeat = widget.alarm.repeat;

  String get _formattedTime {
    return _time.format(context);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newAlarm ? 'Create alarm' : 'Edit alarm'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              child: InkWell(
                onTap: () {
                  _selectTime();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_formattedTime, style: TextStyle(fontSize: 24)),
                ),
              ),
            ),
            M3ETextField(
              controller: _nameController,
              label: 'Name',
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Repeat'),
              value: _repeat,
              onChanged: (value) {
                setState(() {
                  _repeat = value;
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final updated = widget.alarm.copyWith(
            time: _time,
            name: _name,
            repeat: _repeat,
          );
          ref.read(alarmsProvider.notifier).updateAlarm(updated);
          Navigator.of(context).pop();
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
