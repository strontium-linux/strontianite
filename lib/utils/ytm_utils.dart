import 'package:darttubefix/darttubefix.dart';
import 'package:flutter/foundation.dart';
import 'package:strontianite/main.dart';
import 'package:strontianite/providers/settings_provider.dart';
import 'package:strontianite/utils/authenticated_http_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YtmUtils {
  static final _yt = YoutubeExplode(
    httpClient: YoutubeHttpClient(AuthenticatedHttpClient()),
  );
  static List<String> _lastSuggestions = List.empty();

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
    final results = await _yt.search.search(query);
    return results;
  }

  static Future<void> play(VideoId id) async {
    final cookie = container.read(settingsProvider).youtubeCookie;
    final player = audioHandler.getPlayer();

    try {
      debugPrint('Playing: $id');
      final url = 'https://music.youtube.com/watch?v=${id.toString()}';
      final yt = YouTube(url, client: 'WEB_MUSIC');
      final title = await yt.title;
      final artist = await yt.author;
      final artUri = await yt.thumbnailUrl;
      final streams = await yt.streams;
      final length = await yt.length;
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
      } else {
        debugPrint('Audio stream is null.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void dispose() {
    _yt.close();
  }
}
