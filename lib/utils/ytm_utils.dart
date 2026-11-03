import 'dart:convert';

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
  static bool _loadPlaying = false;
  static bool _listening = false;
  static ValueNotifier<PlayModel>? _callback;

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

  static Future<void> play(
    String id,
    ValueNotifier<PlayModel> playCallback,
  ) async {
    _loadPlaying = true;
    _related = null;
    _callback = playCallback;
    _ensureListener();

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
        await player.setUrl(playableUrl, headers: {'Cookie': cookie});
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
      } else {
        debugPrint('Audio stream is null.');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _loadPlaying = false;
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
    await play(_related!, callback);
  }

  static void _ensureListener() {
    if (_listening) return;
    _listening = true;
    audioHandler.getPlayer().processingStateStream.listen((state) {
      if (state == ProcessingState.completed && _callback != null) {
        playRelated(_callback!);
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

    final next = contents[1];
    if (next == null) return null;

    final r =
        next['playlistPanelVideoRenderer'] ??
        next['playlistPanelVideoWrapperRenderer']?['primaryRenderer']?['playlistPanelVideoRenderer'];

    return r['videoId'];
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

  static void dispose() {
    _yt.close();
  }
}
