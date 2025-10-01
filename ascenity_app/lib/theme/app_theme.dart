import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ascenity brand palette
  // Primary accents
  static const Color softBlue = Color(0xFF40D5FF);   // Soft Blue
  static const Color aquamarine = Color(0xFF57FFBB); // Aquamarine
  static const Color blueberry = Color(0xFF497EFF);  // Blueberry
  // Backgrounds / surfaces
  static const Color deepNavy = Color(0xFF07073A);   // Deep Navy
  static const Color lightSurface = Color(0xFFF4F0ED); // Light Gray surface

  static ThemeData lightTheme(Color primarySeed) {
    final swatch = _createMaterialColor(primarySeed);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
    ).copyWith(
      surface: lightSurface,
      surfaceContainerHighest: Colors.white,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme, primarySwatch: swatch);
    return base.copyWith(
      scaffoldBackgroundColor: lightSurface,
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true, surfaceTintColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
      ),
      // Use the base ThemeData's textTheme so GoogleFonts applies consistently
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  static ThemeData darkTheme(Color primarySeed) {
    final swatch = _createMaterialColor(primarySeed);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF0B0B4A),
      surfaceContainerHighest: const Color(0xFF171767),
    );
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme, primarySwatch: swatch);
    return base.copyWith(
      scaffoldBackgroundColor: deepNavy,
      appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true, backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF121259),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => GoogleFonts.inter(
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        indicatorColor: blueberry.withValues(alpha: 0.35),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFF0D0D4E).withValues(alpha: 0.95),
      ),
      // Use the base textTheme so GoogleFonts applies consistently
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  // Helper to create a MaterialColor
  static MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = (color.r * 255.0).round();
    final int g = (color.g * 255.0).round();
    final int b = (color.b * 255.0).round();
  for (int i = 1; i < 10; i++) { strengths.add(0.1 * i); }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }
}
