// Full demo app with all screens.
// Run with: flutter run -t lib/demo_app.dart
import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

import 'screens/home_screen.dart';

void main() => runApp(const DuniyaApp());

class DuniyaApp extends StatefulWidget {
  const DuniyaApp({super.key});
  @override
  State<DuniyaApp> createState() => _DuniyaAppState();
}

class _DuniyaAppState extends State<DuniyaApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duniya',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: const Color(0xFF7F77DD),
        useMaterial3: true,
        extensions: const [DunyaPickerTheme()],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF7F77DD),
        useMaterial3: true,
        extensions: const [DunyaPickerTheme()],
      ),
      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}
