import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF38BDF8);
  static const _surfaceColor = Color(0xFF101D2E);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
          surface: _surfaceColor,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      );
}
