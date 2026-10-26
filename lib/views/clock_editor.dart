import 'package:material_ui/material_ui.dart';
import 'package:strontianite/views/clock.dart';

class ClockEditor extends StatelessWidget {
  const ClockEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit clock'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: EdgeInsets.all(16),
                alignment: AlignmentGeometry.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FittedBox(fit: BoxFit.contain, child: const Clock()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
