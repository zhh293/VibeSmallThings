import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFD700); // Gold/Yellow
  static const Color backgroundColor = Color(0xFF000000); // Pure Black
  static const Color surfaceColor = Color(0xFF121212); // Dark Grey
  static const Color errorColor = Color(0xFFCF6679);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: GoogleFonts.jetBrainsMono().fontFamily,
      bodyColor: Colors.white,
      displayColor: primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Tactical/Sharp look
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ), // Tactical/Sharp look
        side: BorderSide(
          color: Color(0x4DFFD700),
          width: 1,
        ), // primaryColor.withOpacity(0.3)
      ),
    ),
  );
}
