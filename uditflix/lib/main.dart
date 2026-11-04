import 'package:flutter/material.dart';

import 'screens/catalogo_screen.dart';

void main() {
  runApp(const UditflixApp());
}

class UditflixApp extends StatelessWidget {
  const UditflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFE50914),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Uditflix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0B0F),
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const CatalogoScreen(),
    );
  }
}
