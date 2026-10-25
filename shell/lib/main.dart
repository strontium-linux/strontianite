import 'package:material_ui/material_ui.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:turtlinux_shell/views/desktop.dart';

void main() {
  runAppScaled(
    const MainApp(),
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
      home: Scaffold(body: Desktop()),
    );
  }
}
