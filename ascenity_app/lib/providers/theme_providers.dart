// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _themeColor = Colors.teal; // Default color

  Color get themeColor => _themeColor;

  void updateTheme(String mood) {
    _themeColor = _getColorForMood(mood);
    notifyListeners(); // This tells widgets listening to this provider to rebuild
  }

  Color _getColorForMood(String mood) {
    switch (mood) {
      case 'happy': return Colors.amber;
      case 'calm': return Colors.blue;
      case 'neutral': return Colors.grey.shade600;
      case 'sad': return Colors.indigo;
      case 'angry': return Colors.red.shade700;
      default: return Colors.teal;
    }
  }
}