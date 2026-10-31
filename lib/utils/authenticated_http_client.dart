import 'package:http/http.dart' as http;
import 'package:strontianite/main.dart';
import 'package:strontianite/providers/settings_provider.dart';

class AuthenticatedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] =
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36';
    request.headers['cookie'] = container.read(settingsProvider).youtubeCookie;
    return _inner.send(request);
  }
}
