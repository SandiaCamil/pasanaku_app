import 'package:flutter/material.dart';

class Tema {
  static ThemeData get claro => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFB5452B), // tono terracota andino
      secondary: const Color(0xFFE0A526), // dorado
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}