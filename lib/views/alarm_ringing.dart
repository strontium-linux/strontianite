import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/handlers/alarms_handler.dart';
import 'package:strontianite/models/alarm_model.dart';

class AlarmRinging extends StatelessWidget {
  const AlarmRinging({super.key, required this._alarm});

  final AlarmModel _alarm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        AlarmsHandler.dismiss();
      },
      child: Scaffold(
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
              Text(
                _alarm.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontVariations: [FontVariation('ROND', 100)],
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                _alarm.time.format(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontVariations: [FontVariation('ROND', 100)],
                  fontSize: 24,
                ),
              ),
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
      ),
    );
  }
}
