import 'package:flutter/material.dart';

class MediaPanel extends StatefulWidget {
  const MediaPanel({super.key});

  @override
  State<MediaPanel> createState() => _MediaPanelState();
}

class _MediaPanelState extends State<MediaPanel> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Text('Media Name'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: _buildControlButtons(),
        ),
      ],
    );
  }

  List<Widget> _buildControlButtons() {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.skip_previous_outlined),
      ),
      IconButton(
        onPressed: () {},
        icon: _isPlaying
            ? const Icon(Icons.pause_outlined)
            : const Icon(Icons.play_arrow_outlined),
      ),
      IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next_outlined)),
    ];
  }
}
