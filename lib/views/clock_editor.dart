import 'package:material_ui/material_ui.dart';
import 'package:strontianite/enums/clock_type.dart';
import 'package:strontianite/views/clock.dart';

class ClockEditor extends StatefulWidget {
  const ClockEditor({super.key});

  @override
  State<ClockEditor> createState() => _ClockEditorState();
}

class _ClockEditorState extends State<ClockEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit clock'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  _buildClockTemplate(ClockType.flex),
                  _buildClockTemplate(ClockType.flex),
                  _buildClockTemplate(ClockType.flex),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockTemplate(ClockType clockType) {
    return Container(
      width: 300,
      height: 200,
      padding: EdgeInsets.all(16),
      alignment: AlignmentGeometry.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Clock(clockType: clockType),
      ),
    );
  }
}
