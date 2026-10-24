import 'package:flutter/material.dart';
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
              icon: Icons.schedule_outlined,
              exec: () {
                switchPane(0);
              },
            ),
            AppIcon(
              name: 'Media',
              icon: Icons.movie_outlined,
              exec: () {
                switchPane(1);
              },
            ),
            AppIcon(
              name: 'Alarms',
              icon: Icons.alarm_outlined,
              exec: () {
                switchPane(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
