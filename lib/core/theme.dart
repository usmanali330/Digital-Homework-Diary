import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E56A0);
  static const Color darkBlue = Color(0xFF163172);
  static const Color softPink = Color(0xFFFDE8EF);
  static const Color lightBlue = Color(0xFFEAF2FB);
  static const Color accentOrange = Color(0xFFFF8A00);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E56A0),
        primary: const Color(0xFF1E56A0),
        secondary: const Color(0xFF163172),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: lightBlue,
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        bodyMedium: const TextStyle(fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E56A0),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
