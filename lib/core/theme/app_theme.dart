import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF6C63FF);
  static const _secondaryColor = Color(0xFFFF6B9D);
  static const _tertiaryColor = Color(0xFFFECA57);
  static const _errorColor = Color(0xFFEE5A6F);
  static const _successColor = Color(0xFF48DBFB);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      error: _errorColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.notoSansJpTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      tertiary: _tertiaryColor,
      error: _errorColor,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.notoSansJpTextTheme(
      ThemeData.dark().textTheme,
    ).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
}