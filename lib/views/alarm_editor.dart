import 'package:flutter/material.dart';

class AlarmEditor extends StatefulWidget {
  const AlarmEditor({super.key, required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<AlarmEditor> createState() => _AlarmEditorState();
}

class _AlarmEditorState extends State<AlarmEditor> {
  late TimeOfDay _time = widget.initialTime;

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
          spacing: 16,
          children: [
            Row(
              spacing: 16,
              children: [
                Text(_time.format(context)),
                IconButton(
                  onPressed: () => _selectTime(context),
                  icon: const Icon(Icons.schedule_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(BuildContext context) async {
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
