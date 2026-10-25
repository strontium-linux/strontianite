import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:turtlinux_shell/views/app_icon.dart';

class Panel extends StatelessWidget {
  const Panel({super.key, required this.switchPane});

  final Function(int) switchPane;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      padding: EdgeInsets.all(16),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(
              name: 'Clock',
              icon: M3EIcons.schedule_rounded,
              exec: () {
                switchPane(0);
              },
            ),
            AppIcon(
              name: 'Media',
              icon: M3EIcons.movie_rounded,
              exec: () {
                switchPane(1);
              },
            ),
            AppIcon(
              name: 'Alarms',
              icon: M3EIcons.alarm_rounded,
              exec: () {
                switchPane(2);
              },
            ),
            // AppIcon(
            //   name: 'Weather',
            //   icon: M3EIcons.cloud_rounded,
            //   exec: () {
            //     switchPane(2);
            //   },
            // ),
            // AppIcon(
            //   name: 'YouTube Music',
            //   icon: M3EIcons.music_note_rounded,
            //   exec: () {
            //     switchPane(2);
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
