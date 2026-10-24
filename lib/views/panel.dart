import 'package:flutter/material.dart';
import 'package:turtlinux_shell/views/app_icon.dart';

class Panel extends StatelessWidget {
  const Panel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(16)),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      padding: EdgeInsets.all(16),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppIcon(name: 'Alarms', icon: Icons.alarm, exec: 'alarms'),
            AppIcon(
              name: 'Music',
              icon: Icons.music_note_outlined,
              exec: 'music',
            ),
            AppIcon(
              name: 'Camera',
              icon: Icons.camera_alt_outlined,
              exec: 'camera',
            ),
          ],
        ),
      ),
    );
  }
}
