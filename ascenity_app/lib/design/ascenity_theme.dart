import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

ThemeData buildAscenityTheme({TextTheme? baseTextTheme}) {
  final textColor = AscenityColors.oxfordBlue;
  final base = baseTextTheme ?? const TextTheme();
  final textTheme = base.copyWith(
    displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 32, height: 40 / 32),
    headlineLarge: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 28, height: 36 / 28),
    headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 24, height: 32 / 24),
    titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 20, height: 28 / 20),
    bodyLarge: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: 16, height: 24 / 16),
    bodyMedium: TextStyle(color: textColor.withOpacity(0.85), fontWeight: FontWeight.w400, fontSize: 14, height: 22 / 14),
    labelLarge: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
  );

  final lightScheme = ColorScheme.fromSeed(
    seedColor: AscenityColors.honoluluBlue,
    primary: AscenityColors.honoluluBlue, // #027bce (CTA)
    secondary: AscenityColors.robinEggBlue, // #1ccad8 (accents)
    tertiary: AscenityColors.emerald, // #00d37d (success/progress)
    brightness: Brightness.light,
  ).copyWith(
    background: AscenityColors.snow,
    surface: AscenityColors.white,
    surfaceContainerHighest: AscenityColors.white,
    onPrimary: AscenityColors.white,
    onSecondary: AscenityColors.oxfordBlue,
    onSurface: AscenityColors.oxfordBlue,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: lightScheme,
    scaffoldBackgroundColor: AscenityColors.snow,
    textTheme: GoogleFonts.manropeTextTheme(textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AscenityColors.white,
      foregroundColor: AscenityColors.oxfordBlue,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AscenityColors.white,
      elevation: 0,
      shadowColor: AscenityColors.lightShadow.withOpacity(0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AscenityRadii.r20),
      ),
      margin: const EdgeInsets.all(AscenitySpacing.s16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AscenityColors.honoluluBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: AscenitySpacing.s16,
          horizontal: AscenitySpacing.s32,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AscenityRadii.r24),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AscenityColors.oxfordBlue,
        side: BorderSide(color: AscenityColors.robinEggBlue.withOpacity(0.6)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AscenityRadii.r24),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AscenitySpacing.s12,
          horizontal: AscenitySpacing.s24,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AscenityColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AscenityRadii.r16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AscenitySpacing.s16,
        vertical: AscenitySpacing.s16,
      ),
    ),
    dividerColor: AscenityColors.oxfordBlue.withValues(alpha: 0.08),
    splashFactory: InkRipple.splashFactory,
  );
}
