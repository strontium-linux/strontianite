import 'package:flutter/material.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:turtlinux_shell/views/desktop.dart';

void main() {
  runAppScaled(
    const MainApp(),
    scaleFactor: (size) {
      const double scale = 500;
      return size.width / scale;
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurtLinux Shell',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Color(0xFF00A1BC))),
      home: Scaffold(body: Desktop()),
    );
  }
}
