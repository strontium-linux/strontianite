import 'dart:convert';
import 'dart:math';

import 'package:darttubefix/darttubefix.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/models/play_model.dart';
import 'package:strontianite/providers/settings_provider.dart';
import 'package:strontianite/utils/authenticated_http_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_music_explode_dart/youtube_music_explode_dart.dart';

class YtmUtils {
  static final _httpClient = AuthenticatedHttpClient();
  static final _yt = YoutubeExplode(httpClient: YoutubeHttpClient(_httpClient));
  static final _ytm = YoutubeMusicExplode(
    httpClient: YoutubeHttpClient(_httpClient),
  );
  static List<String> _lastSuggestions = List.empty();
  static String _title = 'Not playing';
  static String _artist = 'Unknown artist';
  static String? _thumbnail;
  static String? _related;
  static bool _listening = false;
  static ValueNotifier<PlayModel>? _callback;
  static late Function(bool isLoading) _onLoaded;
  static final List<String> _history = [];
  static int _index = -1;

  static Future<List<String>> getSuggestions(String query) async {
    debugPrint('Searching: $query');
    final suggestions = await _yt.search.getQuerySuggestions(query);
    _lastSuggestions = suggestions;
    return suggestions;
  }

  static List<String> getLastSuggestions() {
    return _lastSuggestions;
  }

  static Future<List<Video>> search(String query) async {
    final results = await _ytm.music.searchSongs(query);
    return results;
  }

  static Future<bool> play(
    String id,
    ValueNotifier<PlayModel> playCallback,
    Function(bool isLoading) onLoaded, {
    bool addToHistory = true,
  }) async {
    _related = null;
    _callback = playCallback;
    _onLoaded = onLoaded;
    _ensureListener();

    onLoaded(true);

    final cookie = container.read(settingsProvider).youtubeCookie;
    final player = audioHandler.getPlayer();

    try {
      debugPrint('Playing: $id');
      final url = 'https://music.youtube.com/watch?v=$id';
      final yt = YouTube(url, client: 'WEB_MUSIC');
      final title = await yt.title;
      final artist = await yt.author;
      final artUri = await yt.thumbnailUrl;
      final streams = await yt.streams;
      final length = await yt.length;

      _title = title;
      _artist = artist;
      _thumbnail = artUri;
      _related = await _getRelated(id);

      final audioStream =
          streams.getAudioOnly(subtype: 'mp4') ?? streams.bestAudio;
      if (audioStream != null) {
        final playableUrl = audioStream.url;
        debugPrint('UR:: $playableUrl');
        await player.setUrl(
          playableUrl,
          headers: {
            'Cookie': cookie,
            'User-Agent':
                'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36',
          },
        );
        player.play();
        audioHandler.updateMetadata(
          title: title,
          artist: artist,
          album: 'Unknown album',
          artUri: artUri,
          duration: Duration(seconds: length),
        );
        playCallback.value = PlayModel(
          title: title,
          artist: artist,
          thumbnail: artUri,
        );
        if (addToHistory) {
          if (_index < _history.length - 1) {
            _history.removeRange(_index + 1, _history.length);
          }
          _history.add(id);
          _index = _history.length - 1;
        }
        return true;
      } else {
        debugPrint('Audio stream is null.');
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      onLoaded(false);
    }
  }

  static Duration getDuration() {
    final player = audioHandler.getPlayer();
    return player.duration ?? Duration(seconds: 1);
  }

  static Duration getPosition() {
    final player = audioHandler.getPlayer();
    return player.position;
  }

  static String getTitle() {
    return _title;
  }

  static String getArtist() {
    return _artist;
  }

  static String? getThumbnail() {
    return _thumbnail;
  }

  static bool isPlaying() {
    final player = audioHandler.getPlayer();
    return player.playing &&
        player.processingState != ProcessingState.completed;
  }

  static void setPlaying(bool playing) {
    if (playing) {
      audioHandler.play();
    } else {
      audioHandler.pause();
    }
  }

  static Future<void> playRelated(ValueNotifier<PlayModel> callback) async {
    if (_related == null) {
      debugPrint('Related is null');
      return;
    }
    await play(_related!, callback, _onLoaded);
  }

  static void _ensureListener() {
    if (_listening) return;
    _listening = true;
    audioHandler.getPlayer().processingStateStream.listen((state) {
      if (state == ProcessingState.completed && _callback != null) {
        next();
      }
    });
  }

  static Future<String?> _getRelated(String id) async {
    final response = await _httpClient.post(
      Uri.parse('https://music.youtube.com/youtubei/v1/next'),
      body: jsonEncode({
        'context': {
          'client': {
            'clientName': 'WEB_REMIX',
            'clientVersion': '1.20261031.09.00',
            'hl': 'en',
            'gl': 'US',
          },
        },
        'videoId': id,
        'playlistId': 'RDAMVM$id',
        'isAudioOnly': true,
      }),
    );

    final json = jsonDecode(response.body);

    final panel =
        json['contents']?['singleColumnMusicWatchNextResultsRenderer']?['tabbedRenderer']?['watchNextTabbedResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['musicQueueRenderer']?['content']?['playlistPanelRenderer'];
    final contents = (panel?['contents'] as List?) ?? [];

    final ids = contents
        .map(
          (c) =>
              (c['playlistPanelVideoRenderer'] ??
              c['playlistPanelVideoWrapperRenderer']?['primaryRenderer']?['playlistPanelVideoRenderer'])?['videoId'],
        )
        .whereType<String>()
        .where((v) => v != id)
        .toList();

    if (ids.isEmpty) return null;

    final fresh = ids.where((v) => !_history.contains(v)).toList();
    final pool = fresh.isNotEmpty ? fresh : ids;
    return pool[Random().nextInt(pool.length)];
  }

  static Future<void> seekTo(double percent) async {
    final position = getDurationFromPercentage(percent);
    await audioHandler.seek(position);
  }

  static Duration getDurationFromPercentage(double percent) {
    final player = audioHandler.getPlayer();
    final position = Duration(
      microseconds:
          ((percent.clamp(0.0, 1.0)) * (player.duration?.inMicroseconds ?? 1))
              .round(),
    );
    return position;
  }

  static Future<void> previous() async {
    if (_index <= 0 || _callback == null) return;
    final target = _index - 1;
    final ok = await play(
      _history[target],
      _callback!,
      _onLoaded,
      addToHistory: false,
    );
    if (ok) _index = target;
  }

  static Future<void> next() async {
    if (_callback == null) return;
    if (_index < _history.length - 1) {
      final target = _index + 1;
      final ok = await play(_history[target], _callback!, _onLoaded);
      if (ok) _index = target;
      return;
    }
    await playRelated(_callback!);
  }

  static void dispose() {
    _yt.close();
  }
}
