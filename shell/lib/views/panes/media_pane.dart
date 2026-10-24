import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:playerctl/playerctl.dart';
import 'package:turtlinux_shell/utils/media_utils.dart';

class MediaPane extends StatefulWidget {
  const MediaPane({super.key});

  @override
  State<MediaPane> createState() => _MediaPaneState();
}

class _MediaPaneState extends State<MediaPane> {
  MediaInfo? _mediaInfo;
  bool _isPlaying = false;
  late StreamSubscription<PlayerState> _streamSubscription;

  @override
  void initState() {
    super.initState();
    MediaUtils.init();
    _mediaInfo = MediaUtils.lastInfo;
    _streamSubscription = MediaUtils.getStateStream().listen((state) {
      if (mounted) {
        setState(() {
          _mediaInfo = state.currentMedia;
          _isPlaying = _mediaInfo?.status.toLowerCase() == 'playing';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        _buildImage(),
        Text(_mediaInfo?.title ?? 'Unknown Song'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: _buildControlButtons(),
        ),
      ],
    );
  }

  @override
  void dispose() async {
    _streamSubscription.cancel();
    super.dispose();
  }

  List<Widget> _buildControlButtons() {
    return [
      IconButton(
        onPressed: () async {
          await MediaUtils.previous();
        },
        icon: const Icon(Icons.skip_previous_outlined),
      ),
      IconButton(
        onPressed: () async {
          if (_isPlaying) {
            if (mounted) {
              setState(() {
                _isPlaying = false;
              });
            }
            await MediaUtils.pause();
          } else {
            if (mounted) {
              setState(() {
                _isPlaying = true;
              });
            }
            await MediaUtils.play();
          }
        },
        icon: _isPlaying
            ? const Icon(Icons.pause_outlined)
            : const Icon(Icons.play_arrow_outlined),
      ),
      IconButton(
        onPressed: () async {
          await MediaUtils.next();
        },
        icon: const Icon(Icons.skip_next_outlined),
      ),
    ];
  }

  Widget _buildImage() {
    return M3EContainer.pill(child: _buildImageCore());
  }

  Widget _buildImageCore() {
    if (_mediaInfo?.artUrl == null) {
      return _buildDefaultImage();
    }

    final uri = Uri.tryParse(_mediaInfo!.artUrl!);
    if (uri == null) {
      return _buildDefaultImage();
    }

    Widget fallback(c, e, s) => _buildDefaultImage();

    switch (uri.scheme) {
      case 'file':
        return Image.file(File(uri.toFilePath()), errorBuilder: fallback);
      case 'http':
      case 'https':
        return Image.network(_mediaInfo!.artUrl!, errorBuilder: fallback);
      case 'data':
        return Image.memory(uri.data!.contentAsBytes(), errorBuilder: fallback);
      default:
        return _buildDefaultImage();
    }
  }

  Widget _buildDefaultImage() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          Icons.music_note_outlined,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
