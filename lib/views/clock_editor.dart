import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:strontianite/enums/clock_type.dart';
import 'package:strontianite/providers/clock_type_provider.dart';
import 'package:strontianite/providers/settings_provider.dart';
import 'package:strontianite/views/clock.dart';

class ClockEditor extends ConsumerStatefulWidget {
  const ClockEditor({super.key});

  @override
  ConsumerState<ClockEditor> createState() => _ClockEditorState();
}

class _ClockEditorState extends ConsumerState<ClockEditor> {
  @override
  Widget build(BuildContext context) {
    final displayBatteryIndicator = ref.watch(
      settingsProvider.select((state) => state.displayBatteryIndicator),
    );
    final isHorizontal = ref.watch(
      settingsProvider.select((state) => state.isHorizontal),
    );

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
                  _buildClockTemplate(ClockType.frameWeathervf),
                  _buildClockTemplate(ClockType.growth),
                  _buildClockTemplate(ClockType.inflatevf),
                  _buildClockTemplate(ClockType.rotationgx),
                  _buildClockTemplate(ClockType.rubyRegular),
                ],
              ),
            ),
            SwitchListTile(
              value: displayBatteryIndicator,
              title: const Text('Display battery indicator'),
              subtitle: const Text(
                'Display battery indicator in the top right of the screen',
              ),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateBatteryPreference(value);
              },
            ),
            SwitchListTile(
              value: isHorizontal,
              title: const Text('Horizontal clock face'),
              subtitle: const Text('Set clock face orientation to horizontal'),
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .updateHorizontalPreference(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClockTemplate(ClockType clockType) {
    return Material(
      child: InkWell(
        onTap: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully set clock style')),
          );
          await ref.read(clockTypeProvider.notifier).setClockType(clockType);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 300,
          height: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Clock(clockType: clockType),
          ),
        ),
      ),
    );
  }
}
