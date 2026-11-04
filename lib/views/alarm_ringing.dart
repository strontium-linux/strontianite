import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/handlers/alarms_handler.dart';
import 'package:strontianite/models/alarm.dart';

class AlarmRinging extends StatelessWidget {
  const AlarmRinging({super.key, required this._alarm});

  final Alarm _alarm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm ringing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            const Icon(M3EIcons.alarm_rounded),
            Text(_alarm.time.format(context), textAlign: TextAlign.center),
            Text(_alarm.name, textAlign: TextAlign.center),
            M3EButton.filled(
              onPressed: () {
                AlarmsHandler.dismiss();
                Navigator.pop(context);
              },
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }
}
