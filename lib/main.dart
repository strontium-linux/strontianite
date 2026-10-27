import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strontianite/views/desktop.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

void main() async {
  final prefs = await SharedPreferences.getInstance();

  runAppScaled(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MainApp(),
    ),
    scaleFactor: (size) {
      const double scale = 600;
      return size.width / scale;
    },
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
