import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_media_controller/flutter_media_controller.dart' as fmc;
import 'package:playerctl/playerctl.dart';

class MediaUtils {
  static final _manager = MediaPlayerManager(logLevel: LogLevel.none);
  static Future<void>? _initFuture;
  static MediaInfo? lastInfo;

  static Future<void> init() => _initFuture ??= _init();

  static Future<void> _init() async {
    if (Platform.isLinux) {
      PlayerctlLogger.level = LogLevel.none;
      await _manager.initialize();
      debugPrint('Initialized media player manager');
      _manager.stateStream.listen((state) {
        lastInfo = state.currentMedia;
      });
    }
  }

  static Future<void> play() async {
    if (Platform.isLinux) {
      await _manager.play();
    } else if (Platform.isAndroid) {
      await fmc.FlutterMediaController.togglePlayPause();
    }
  }

  static Future<void> pause() async {
    if (Platform.isLinux) {
      await _manager.pause();
    } else if (Platform.isAndroid) {
      await fmc.FlutterMediaController.togglePlayPause();
    }
  }

  static Future<void> next() async {
    if (Platform.isLinux) {
      await _manager.next();
    } else if (Platform.isAndroid) {
      await fmc.FlutterMediaController.nextTrack();
    }
  }

  static Future<void> previous() async {
    if (Platform.isLinux) {
      await _manager.previous();
    } else if (Platform.isAndroid) {
      await fmc.FlutterMediaController.previousTrack();
    }
  }

  static Future<void> seekTo(int pos) async {
    await _manager.seekTo(pos);
  }

  static Future<void> shuffle() async {
    await _manager.toggleShuffle();
  }

  static int getVolume() {
    return _manager.volume;
  }

  static Future<void> setVolume(int volume) async {
    await _manager.setVolume(volume);
  }

  static Future<void> dispose() async {
    _manager.dispose();
  }

  static Stream<PlayerState> getStateStream() {
    return _manager.stateStream;
  }

  static Stream<fmc.MediaInfo> getMediaInfoAndroidStream() async* {
    while (true) {
      try {
        yield await fmc.FlutterMediaController.getCurrentMediaInfo();
      } catch (e) {
        debugPrint(e.toString());
      }

      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
