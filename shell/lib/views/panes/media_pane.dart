import 'dart:async';
import 'dart:io';
import 'dart:math';

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
  bool _isChanging = false;
  int _currentPosition = 0;
  late Timer _timer;
  int _volume = 100;
  bool _isVolChanging = false;

  int get _length {
    final l = _mediaInfo?.length ?? 0;
    return l <= 0 ? 1 : l;
  }

  double get _sliderValue => (_currentPosition / _length).clamp(0.0, 1.0);
  String get _elapsed =>
      '${_microsecondsToTimestamp(_currentPosition)} / ${_microsecondsToTimestamp(_length)}';

  @override
  void initState() {
    super.initState();
    MediaUtils.init();
    _mediaInfo = MediaUtils.lastInfo;
    _isPlaying = _mediaInfo?.status.toLowerCase() == 'playing';
    if (!_isChanging) _currentPosition = _mediaInfo?.position ?? 0;
    if (!_isVolChanging) _volume = MediaUtils.getVolume();

    _streamSubscription = MediaUtils.getStateStream().listen((state) {
      if (mounted) {
        setState(() {
          _mediaInfo = state.currentMedia;
          _isPlaying = _mediaInfo?.status.toLowerCase() == 'playing';
          if (!_isChanging) _currentPosition = _mediaInfo?.position ?? 0;
          if (!_isVolChanging) _volume = state.volume;
        });
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isPlaying) {
        setState(() {
          if (!_isChanging) _currentPosition = _mediaInfo?.position ?? 0;
          _currentPosition = min(_currentPosition + 500000, _length);
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
        Text(
          _mediaInfo?.title ?? 'Unknown Song',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontVariations: [FontVariation.width(125)],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(showValueIndicator: ShowValueIndicator.onDrag),
          child: Slider(
            value: _sliderValue,
            label: '${(_currentPosition * 0.000001).round().toString()}s',
            onChanged: (value) {
              setState(() {
                _currentPosition = (value * _length).round();
              });
            },
            onChangeStart: (value) {
              debugPrint('Change start');
              _isChanging = true;
            },
            onChangeEnd: (value) async {
              debugPrint('Change end, current position: $_currentPosition');
              debugPrint('Max position: $_length');
              // IMPORTANT: playerctl wrapper passes us to playerctl which takes seconds
              await MediaUtils.seekTo(_currentPosition ~/ 1000000);
              _isChanging = false;
            },
          ),
        ),
        Text(_elapsed),
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
    _timer.cancel();
    super.dispose();
  }

  List<Widget> _buildControlButtons() {
    return [
      IconButton(
        onPressed: () async {
          await MediaUtils.shuffle();
        },
        icon: const Icon(Icons.shuffle),
      ),
      IconButton.filledTonal(
        onPressed: () async {
          await MediaUtils.previous();
        },
        icon: const Icon(Icons.skip_previous_outlined),
      ),
      IconButton.filled(
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
      IconButton.filledTonal(
        onPressed: () async {
          await MediaUtils.next();
        },
        icon: const Icon(Icons.skip_next_outlined),
      ),
      IconButton(
        onPressed: () async {
          _showVolumeDialog();
        },
        icon: const Icon(Icons.volume_up_outlined),
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

  String _microsecondsToTimestamp(int us) {
    return Duration(
      microseconds: us,
    ).toString().split('.').first.padLeft(8, '0');
  }

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjust volume'),
        content: StatefulBuilder(
          builder: (context, setState) => SliderTheme(
            data: SliderThemeData(
              showValueIndicator: ShowValueIndicator.onDrag,
            ),
            child: Slider(
              value: _volume / 100,
              label: _volume.toString(),
              onChanged: (vol) async {
                setState(() {
                  _volume = (vol * 100).round();
                });
              },
              onChangeStart: (vol) {
                _isVolChanging = true;
              },
              onChangeEnd: (vol) async {
                await MediaUtils.setVolume(_volume);
                _isVolChanging = false;
              },
            ),
          ),
        ),
      ),
    );
  }
}
