import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_ui/material_ui.dart';

class AlarmRinging extends StatelessWidget {
  const AlarmRinging({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm ringing'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          const Icon(M3EIcons.alarm_rounded),
          M3EButton.filled(onPressed: () {}, child: const Text('Dismiss')),
        ],
      ),
    );
  }
}
