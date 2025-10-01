# Ascenity App

A Flutter application for mental wellness and mindfulness tracking.

## Project Structure

```
lib/
├── extensions/       # Extension methods for existing classes
├── models/           # Data models and schemas
├── providers/        # State management providers
├── screens/          # UI screens and pages
├── services/         # Backend and business logic services
├── theme/            # Theming and styling
├── utils/            # Utility functions and helpers
├── widgets/          # Reusable UI components
├── firebase_options.dart  # Firebase configuration
└── main.dart         # Application entry point
```

## Features

- User authentication with Firebase
- Daily mood tracking
- Journaling with sentiment analysis
- Streaks and progress tracking
- Custom animations and transitions
- Dark and light theme support

## Dependencies

- Flutter SDK: ^3.9.2
- firebase_core: ^4.1.1
- firebase_auth: ^6.1.0
- cloud_firestore: ^6.0.2
- provider: ^6.1.5+1
- google_sign_in: ^5.4.2
- google_fonts: ^6.3.2
- fl_chart: ^0.69.0
- lottie: ^3.3.2
- animations: ^2.0.11
- flutter_staggered_animations: ^1.1.1

## Getting Started

1. Ensure you have Flutter installed and setup
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (using Firebase console and FlutterFire CLI)
4. Run the app with `flutter run`

## Architecture

The app follows a layered architecture:

- **UI Layer**: Screens and Widgets
- **Business Logic Layer**: Services and Providers
- **Data Layer**: Models and Firebase services

## Navigation

The app uses a custom navigation system with:
- Bottom navigation bar for main sections
- Custom page transitions for a fluid UX
- Hero animations for related content

## Custom Components

- `ColorExtensions`: Utility methods for the Color class
- `AppTheme`: Centralized theme management
- `CustomNavBar`: Animated navigation component
- `AppRoutes`: Custom route transitions

## Development Guidelines

- Use providers for state management
- Follow Material Design 3 principles
- Implement haptic feedback for better UX
- Keep animations subtle and purposeful
- Document public APIs and complex logic
