import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:flutter_m3shapes_extended/flutter_m3shapes_extended.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:playerctl/playerctl.dart';
import 'package:strontianite/utils/media_utils.dart';
import 'package:flutter_media_controller/flutter_media_controller.dart' as fmc;

class MediaPane extends StatefulWidget {
  const MediaPane({super.key});

  @override
  State<MediaPane> createState() => _MediaPaneState();
}

class _MediaPaneState extends State<MediaPane> {
  MediaInfo? _mediaInfo;
  bool _isPlaying = false;
  late StreamSubscription<PlayerState> _linuxStreamSubscription;
  late StreamSubscription<fmc.MediaInfo> _androidStreamSubscription;
  int _anchorPosition = 0;
  int _volume = 100;
  final Stopwatch _posStopwatch = Stopwatch();
  late Timer _timer;
  int? _seekPosition;
  DateTime _ignorePositionUntil = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _ignorePlayStateUntil = DateTime.fromMillisecondsSinceEpoch(0);
  Shapes _currentShape = Shapes.pill;
  final List<Shapes> _mediaShapes = [
    Shapes.pill,
    Shapes.arrow,
    Shapes.arch,
    Shapes.square,
    Shapes.c4SidedCookie,
    Shapes.c6SidedCookie,
    Shapes.c7SidedCookie,
    Shapes.c9SidedCookie,
    Shapes.circle,
    Shapes.bun,
  ];

  int get _length {
    final l = _mediaInfo?.length ?? 0;
    return l <= 0 ? 1 : l;
  }

  int get _livePosition {
    if (!_isPlaying) return _anchorPosition;
    return min(_anchorPosition + _posStopwatch.elapsedMicroseconds, _length);
  }

  int get _displayPosition => _seekPosition ?? _livePosition;
  double get _sliderValue => (_displayPosition / _length).clamp(0.0, 1.0);
  String get _elapsed =>
      '${_microsecondsToTimestamp(_displayPosition)} / ${_microsecondsToTimestamp(_length)}';

  bool get _noMedia =>
      _mediaInfo == null || _mediaInfo?.status.toLowerCase() == 'stopped';

  @override
  void initState() {
    super.initState();
    MediaUtils.init();
    _mediaInfo = MediaUtils.lastInfo;
    _isPlaying = _mediaInfo?.status.toLowerCase() == 'playing';
    _reanchor(_mediaInfo?.position ?? 0);
    _volume = MediaUtils.getVolume();

    _linuxStreamSubscription = MediaUtils.getStateStream().listen((state) {
      if (mounted) {
        setState(() {
          final newPos = state.currentMedia.position ?? 0;
          final trackChanged = state.currentMedia.title != _mediaInfo?.title;
          final offset = (newPos - _livePosition).abs();

          _mediaInfo = state.currentMedia;
          debugPrint('Media info: $_mediaInfo');
          if (_canUpdatePlayState()) {
            final nowPlaying =
                (_mediaInfo?.status.toLowerCase() == 'playing') ||
                _mediaInfo == null;
            debugPrint('Now playing: $nowPlaying');
            if (nowPlaying != _isPlaying) _reanchor(_livePosition);
            _isPlaying = nowPlaying;
          }
          _volume = state.volume;

          final ignorePos =
              _seekPosition != null ||
              DateTime.now().isBefore(_ignorePositionUntil);

          if (trackChanged) {
            _seekPosition = null;
            _reanchor(newPos);
          } else if (!ignorePos && (offset > 3000000 || !_isPlaying)) {
            _reanchor(newPos);
          }
        });
      }
    });

    _androidStreamSubscription = MediaUtils.getMediaInfoAndroidStream().listen((
      info,
    ) {
      if (mounted) {
        setState(() {
          _mediaInfo = MediaInfo(
            title: info.track,
            artist: info.artist,
            status: info.isPlaying ? 'Playing' : 'Paused',
            artUrl: info.thumbnailUrl,
          );
          debugPrint('Media info: $_mediaInfo');
          if (_canUpdatePlayState()) {
            final nowPlaying =
                (_mediaInfo?.status.toLowerCase() == 'playing') ||
                _mediaInfo == null;
            debugPrint('Now playing: $nowPlaying');
            if (nowPlaying != _isPlaying) _reanchor(_livePosition);
            _isPlaying = nowPlaying;
          }
          _volume = 100;
        });
      }
    });

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_isPlaying && mounted) {
        setState(() {});
      }
    });

    _changeShape();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(
              (_noMedia || _mediaInfo?.title == null)
                  ? 'No media'
                  : _mediaInfo!.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                fontVariations: [FontVariation('ROND', 100)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            _mediaInfo?.artist ?? 'Unknown Artist',
            style: TextStyle(fontSize: 11),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SliderTheme(
              data: SliderThemeData(
                showValueIndicator: ShowValueIndicator.onDrag,
              ),
              child: M3ESlider(
                value: _sliderValue,
                label: '${(_displayPosition * 0.000001).round().toString()}s',
                enabled: !_noMedia && Platform.isLinux,
                onChanged: (value) {
                  setState(() {
                    _seekPosition = (value * _length).round();
                  });
                },
                onChangeEnd: (value) async {
                  debugPrint('Change end, current position: $_anchorPosition');
                  debugPrint('Max position: $_length');
                  final target = (value * _length).round();
                  setState(() {
                    _reanchor(target);
                    _seekPosition = null;
                    _ignorePositionUntil = DateTime.now().add(
                      const Duration(seconds: 3),
                    );
                  });
                  // IMPORTANT: playerctl wrapper passes us to playerctl which takes seconds
                  await MediaUtils.seekTo(target ~/ 1000000);
                },
              ),
            ),
          ),
          Text(_elapsed, style: TextStyle(fontSize: 11)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: _buildControlButtons(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _linuxStreamSubscription.cancel();
    _androidStreamSubscription.cancel();
    _timer.cancel();
    super.dispose();
  }

  List<Widget> _buildControlButtons() {
    return [
      M3EIconButton(
        onPressed: () async {
          await MediaUtils.shuffle();
        },
        icon: const Icon(M3EIcons.shuffle),
      ),
      M3EIconButton(
        variant: M3EIconButtonVariant.tonal,
        onPressed: () async {
          await MediaUtils.previous();
        },
        icon: const Icon(M3EIcons.skip_previous_rounded),
      ),
      M3EIconButton(
        variant: M3EIconButtonVariant.filled,
        onPressed: () async {
          if (Platform.isAndroid) {
            final status = await Permission.notification.status;
            if (!status.isGranted) {
              _showPermissionDialog();
              return;
            }
          }

          if (_isPlaying) {
            if (mounted) {
              setState(() {
                _optimisticPlayToggle(false);
              });
            }
            await MediaUtils.pause();
          } else {
            if (mounted) {
              setState(() {
                _optimisticPlayToggle(true);
              });
            }
            await MediaUtils.play();
          }
        },
        icon: _isPlaying
            ? const Icon(M3EIcons.pause_rounded)
            : const Icon(M3EIcons.play_arrow_rounded),
      ),
      M3EIconButton(
        variant: M3EIconButtonVariant.tonal,
        onPressed: () async {
          await MediaUtils.next();
        },
        icon: const Icon(M3EIcons.skip_next_rounded),
      ),
      M3EIconButton(
        onPressed: () {
          _showVolumeDialog();
        },
        icon: const Icon(M3EIcons.volume_up_rounded),
      ),
    ];
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: _changeShape,
      child: M3EContainer(
        key: ValueKey(_currentShape),
        _currentShape,
        width: 100,
        height: 100,
        child: _buildImageCore(),
      ),
    );
  }

  Widget _buildImageCore() {
    if (_mediaInfo?.artUrl == null) {
      return _buildDefaultImage();
    }

    Widget fallback(c, e, s) => _buildDefaultImage();

    final uri = Uri.tryParse(_mediaInfo!.artUrl!);
    if (uri == null) {
      return _buildDefaultImage();
    }

    debugPrint('Uri scheme: ${uri.scheme}');

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
          M3EIcons.music_note_rounded,
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
    debugPrint('Volume: $_volume');
    showDialog(
      context: context,
      builder: (context) => M3EDialog(
        title: 'Adjust volume',
        content: StatefulBuilder(
          builder: (context, setState) => SliderTheme(
            data: SliderThemeData(
              showValueIndicator: ShowValueIndicator.onDrag,
            ),
            child: M3ESlider(
              value: _volume / 100,
              label: _volume.toString(),
              enabled: Platform.isLinux,
              onChanged: (vol) async {
                setState(() {
                  _volume = (vol * 100).round();
                });
              },
              onChangeEnd: (vol) async {
                await MediaUtils.setVolume(_volume);
              },
            ),
          ),
        ),
        actions: [
          M3EButton.filled(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [Icon(M3EIcons.check_rounded), Text('OK')],
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => M3EDialog(
        title: 'Permission required',
        content: const Text(
          'Strontianite requires the notification permission to control your media',
        ),
        actions: [
          M3EButton.filled(
            onPressed: () async {
              fmc.FlutterMediaController.requestPermissions();
              if (mounted) Navigator.pop(context);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [Icon(M3EIcons.check_rounded), Text('Grant')],
            ),
          ),
        ],
      ),
    );
  }

  void _optimisticPlayToggle(bool playing) {
    _reanchor(_livePosition);
    _isPlaying = playing;
    _ignorePlayStateUntil = DateTime.now().add(const Duration(seconds: 3));
  }

  bool _canUpdatePlayState() {
    return DateTime.now().isAfter(_ignorePlayStateUntil);
  }

  void _reanchor(int pos) {
    _anchorPosition = pos;
    _posStopwatch
      ..reset()
      ..start();
  }

  void _changeShape() {
    setState(() {
      debugPrint('Changing shape');
      final options = _mediaShapes.where((s) => s != _currentShape).toList();
      _currentShape = options[Random().nextInt(options.length)];
      debugPrint('Current shape: $_currentShape');
    });
  }
}
