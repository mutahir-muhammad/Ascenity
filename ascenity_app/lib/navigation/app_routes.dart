import 'package:flutter/material.dart';

/// Custom route factory to create page transitions for the app.
class AppRoutes {
  /// Creates a hero-based page transition route for navigating to details pages.
  static Route<T> heroRoute<T>({
    required BuildContext context,
    required Widget page,
    required String heroTag,
  }) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
        );
        
        var scaleAnimation = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(scaleAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Creates a smooth vertical slide transition for modals.
  static Route<T> modalRoute<T>({
    required Widget page,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        
        var slideAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.15),
              end: Offset.zero,
            ).animate(slideAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Creates a shared axis transition for tab-like navigation.
  static Route<T> horizontalRoute<T>({
    required Widget page,
    bool forward = true,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        
        var slideAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(forward ? 0.15 : -0.15, 0.0),
              end: Offset.zero,
            ).animate(slideAnimation),
            child: child,
          ),
        );
      },
    );
  }
}