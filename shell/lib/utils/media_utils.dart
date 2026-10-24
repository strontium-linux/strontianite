import 'package:flutter/foundation.dart';
import 'package:playerctl/playerctl.dart';

class MediaUtils {
  static final _manager = MediaPlayerManager(logLevel: LogLevel.none);
  static Future<void>? _initFuture;
  static MediaInfo? lastInfo;

  static Future<void> init() => _initFuture ??= _init();

  static Future<void> _init() async {
    PlayerctlLogger.level = LogLevel.none;
    await _manager.initialize();
    debugPrint('Initialized media player manager');
    _manager.stateStream.listen((state) {
      lastInfo = state.currentMedia;
    });
  }

  static Future<void> play() async {
    await _manager.play();
  }

  static Future<void> pause() async {
    await _manager.pause();
  }

  static Future<void> next() async {
    await _manager.next();
  }

  static Future<void> previous() async {
    await _manager.previous();
  }

  static Future<void> dispose() async {
    _manager.dispose();
  }

  static Stream<PlayerState> getStateStream() {
    return _manager.stateStream;
  }
}
