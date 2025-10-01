import 'package:flutter/material.dart';

/// Custom route transitions for the Ascenity app.
/// This utility class provides factory methods for common transition types.
class AppRoutes {
  /// Creates a route with a hero-like transition.
  /// Good for transitions between related details.
  static Route<T> heroRoute<T>({
    required Widget destination, 
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOut;
        var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
        return FadeTransition(
          opacity: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Creates a route with a bottom-up modal transition.
  /// Good for dialogs, sheets, and detail views.
  static Route<T> modalRoute<T>({
    required Widget destination,
    required RouteSettings settings,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOut;
        var curveTween = CurveTween(curve: curve);
        var begin = const Offset(0.0, 0.2);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(curveTween);
        
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(Tween(begin: 0.0, end: 1.0).chain(curveTween)),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  /// Creates a route with horizontal slide transition.
  /// Good for navigation between sibling pages.
  static Route<T> horizontalRoute<T>({
    required Widget destination,
    required RouteSettings settings,
    bool rightToLeft = true,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeInOut;
        var curveTween = CurveTween(curve: curve);
        
        var begin = Offset(rightToLeft ? 1.0 : -1.0, 0.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end).chain(curveTween);
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  /// Creates a route with a fade through color transition.
  /// Good for major theme changes or section switches.
  static Route<T> fadeThrough<T>({
    required Widget destination,
    required RouteSettings settings,
    Color? color,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.7, curve: Curves.fastOutSlowIn),
          ),
        );
        
        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.3, 1.0, curve: Curves.fastOutSlowIn),
          ),
        );
        
        return Stack(
          children: [
            FadeTransition(
              opacity: fadeOut,
              child: Container(color: color ?? Theme.of(context).scaffoldBackgroundColor),
            ),
            FadeTransition(
              opacity: fadeIn,
              child: child,
            ),
          ],
        );
      },
      transitionDuration: duration,
    );
  }
}