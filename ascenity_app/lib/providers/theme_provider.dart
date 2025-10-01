import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:ascenity_app/design/ascenity_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ascenity_app/design/tokens.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefsKeyThemeMode = 'ascenity_theme_mode';
  // Predefined color schemes for different moods
  static final Map<String, ColorScheme> _moodColorSchemes = {
    'happy': ColorScheme.fromSeed(
      seedColor: const Color(0xFF57FFBB),
      brightness: Brightness.light,
    ),
    'calm': ColorScheme.fromSeed(
      seedColor: const Color(0xFF40D5FF),
      brightness: Brightness.light,
    ),
    'neutral': ColorScheme.fromSeed(
      seedColor: const Color(0xFF9E9E9E),
      brightness: Brightness.light,
    ),
    'sad': ColorScheme.fromSeed(
      seedColor: const Color(0xFF6C5CE7),
      brightness: Brightness.light,
    ),
    'angry': ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5252),
      brightness: Brightness.light,
    ),
  };

  ColorScheme _colorScheme = _moodColorSchemes['calm']!;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadPersistedThemeMode();
  }

  ThemeMode get themeMode => _themeMode;
  ColorScheme get colorScheme => _colorScheme;

  ThemeData get lightTheme {
    final base = buildAscenityTheme();
    return base.copyWith(
      colorScheme: _colorScheme,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.iOS: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.linux: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.macOS: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.windows: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.fuchsia: const SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
        },
      ),
    );
  }

  ThemeData get darkTheme {
    // Dark theme per brief: Oxford Blue background, #1E2A47 surfaces, Snow text
    final baseLight = buildAscenityTheme();
    final scheme = ColorScheme.fromSeed(
      seedColor: AscenityColors.honoluluBlue,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AscenityColors.honoluluBlue,
      secondary: AscenityColors.robinEggBlue,
      tertiary: AscenityColors.emerald,
      background: AscenityColors.oxfordBlue,
      surface: AscenityColors.darkSurface,
      surfaceContainerHighest: AscenityColors.darkSurface,
      onSurface: AscenityColors.snow,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AscenityColors.oxfordBlue,
      textTheme: baseLight.textTheme.apply(
        bodyColor: AscenityColors.snow,
        displayColor: AscenityColors.snow,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AscenityColors.snow,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: AscenityColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.all(12),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      inputDecorationTheme: baseLight.inputDecorationTheme.copyWith(
        fillColor: AscenityColors.darkSurface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.macOS: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.windows: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
          TargetPlatform.fuchsia: SharedAxisPageTransitionsBuilder(
            transitionType: SharedAxisTransitionType.scaled,
          ),
        },
      ),
    );
  }

  void updateThemeForMood(String mood) {
    final newColorScheme = _moodColorSchemes[mood.toLowerCase()];
    if (newColorScheme != null) {
      _colorScheme = newColorScheme;
      notifyListeners();
    }
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    _persistThemeMode();
  }

  Future<void> _persistThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKeyThemeMode,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {
      // ignore persistence errors silently
    }
  }

  Future<void> _loadPersistedThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_prefsKeyThemeMode);
      if (str == 'dark') {
        _themeMode = ThemeMode.dark;
        notifyListeners();
      } else if (str == 'light') {
        _themeMode = ThemeMode.light;
        notifyListeners();
      }
    } catch (_) {
      // ignore load errors
    }
  }
}