import 'package:flutter/material.dart';

/// Extension methods for the [Color] class.
extension ColorExtensions on Color {
  /// Returns a copy of this color with the specified alpha value.
  /// The [alpha] parameter should be in the range [0.0, 1.0].
  Color withValues({double? red, double? green, double? blue, double? alpha}) {
    return Color.fromARGB(
      alpha != null ? (alpha * 255).round() : this.alpha,
      red != null ? (red * 255).round() : this.red,
      green != null ? (green * 255).round() : this.green,
      blue != null ? (blue * 255).round() : this.blue,
    );
  }
}