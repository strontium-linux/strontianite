import 'package:material_ui/material_ui.dart';
import 'package:strontianite/enums/clock_type.dart';
import 'package:strontianite/views/battery_indicator.dart';
import 'package:strontianite/views/clock.dart';
import 'package:strontianite/views/clock_editor.dart';

class ClockPane extends StatelessWidget {
  const ClockPane({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        debugPrint('long press detected');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClockEditor()),
        );
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: AlignmentGeometry.centerRight,
                child: SizedBox(
                  width: 32,
                  height: 16,
                  child: Stack(
                    alignment: AlignmentGeometry.center,
                    children: [const BatteryIndicator()],
                  ),
                ),
              ),
            ),
            Expanded(child: const Clock(clockType: ClockType.flex)),
          ],
        ),
      ),
    );
  }
}
