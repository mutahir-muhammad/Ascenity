import 'package:flutter/material.dart';

/// Design tokens for Ascenity – minimalist, airy, uplifting.
class AscenityColors {
  // Brand/base
  static const Color snow = Color(0xFFFCF7F8); // Background
  static const Color white = Color(0xFFFFFFFF); // Surfaces
  static const Color darkSurface = Color(0xFF1E2A47); // Dark surf/cards

  // Accents
  static const Color honoluluBlue = Color(0xFF027BCE); // Primary action
  static const Color robinEggBlue = Color(0xFF1CCAD8); // Secondary/gradients
  static const Color emerald = Color(0xFF00D37D); // Success/progress

  // Text
  static const Color oxfordBlue = Color(0xFF0A2239);

  // Shadows / dividers (use withOpacity as needed)
  static const Color shadowBase = oxfordBlue; // apply low opacity (0.08 ~ 0.10)
  static const Color lightShadow = Color(0xFFDDE5ED); // soft card shadow on light
}

class AscenityRadii {
  static const double r16 = 16;
  static const double r20 = 20;
  static const double r24 = 24;
}

class AscenitySpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
}

class AscenityShadows {
  static List<BoxShadow> soft = [
    BoxShadow(
      color: AscenityColors.lightShadow.withOpacity(0.5),
      blurRadius: 12,
      offset: const Offset(0, 4),
    )
  ];

  static List<BoxShadow> raised = [
    BoxShadow(
      color: AscenityColors.lightShadow.withOpacity(0.6),
      blurRadius: 20,
      offset: const Offset(0, 8),
    )
  ];
}
