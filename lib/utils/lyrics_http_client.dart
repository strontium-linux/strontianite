import 'package:http/http.dart' as http;

class LyricsHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = 'SimpMusicLyrics/1.0';
    return _inner.send(request);
  }
}
