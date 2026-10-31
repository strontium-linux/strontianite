import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strontianite/handlers/audio_handler.dart';
import 'package:strontianite/views/desktop.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

late ProviderContainer container;

late MyAudioHandler audioHandler;

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (size) {
      const double scale = 600;
      return size.width / scale;
    },
  );

  final prefs = await SharedPreferences.getInstance();

  JustAudioMediaKit.ensureInitialized();

  container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );

  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'dev.ingstudios.strontianite.channel.audio',
      androidNotificationChannelName: 'Strontianite Audio Playback',
      androidNotificationOngoing: true,
    ),
  );

  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return M3EMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TurtLinux Shell',
      data: M3EThemeData(colorScheme: .fromSeed(Color(0xFF00A1BC))),
      fontFamily: 'Google Sans Flex',
      autoTheming: true,
      dynamicColoring: true,
      drawUnderSystemBars: true,
      home: SafeArea(child: Scaffold(body: Desktop())),
    );
  }
}
