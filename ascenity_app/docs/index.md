# Ascenity App Documentation

Welcome to the Ascenity App documentation. This guide provides comprehensive information about the app's architecture, components, and development guidelines.

## Table of Contents

### Architecture and Design
- [Architecture Overview](architecture.md)
- [Color System](color_system.md)
- [Animation Guidelines](animation_guidelines.md)

### Components
- [Custom Navigation Bar](custom_nav_bar.md)

### User Experience
- [Onboarding Flow](onboarding_flow.md)

### Features
- [Journaling Feature](journaling_feature.md)
- [Mood Tracking Feature](mood_tracking_feature.md)
- [Streak Tracking Feature](streak_tracking_feature.md)

### Integration
- [Firebase Integration](firebase_integration.md)

## Getting Started

If you're new to the project, we recommend starting with the [Architecture Overview](architecture.md) to understand the high-level structure of the application. Then, explore the specific components and guidelines based on your area of focus.

## Development Guidelines

### Code Style

- Follow the [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- Use meaningful variable and method names
- Include documentation comments for public APIs
- Separate UI and business logic

### Workflow

1. Create a feature branch from `develop`
2. Implement the feature or fix
3. Test on multiple devices/platforms
4. Submit a pull request for review
5. Address review comments
6. Merge to `develop` after approval

### Testing

- Write unit tests for services and utilities
- Write widget tests for UI components
- Perform manual testing on real devices

## Project Structure

```
ascenity_app/
├── lib/
│   ├── extensions/       # Extension methods
│   ├── models/           # Data models
│   ├── providers/        # State management
│   ├── screens/          # App screens
│   ├── services/         # Business logic
│   ├── theme/            # Theme configuration
│   ├── utils/            # Utility functions
│   ├── widgets/          # Reusable widgets
│   ├── firebase_options.dart  # Firebase config
│   └── main.dart         # Entry point
├── test/                 # Test files
├── assets/               # Images, animations, etc.
├── docs/                 # Documentation
├── android/              # Android-specific files
├── ios/                  # iOS-specific files
├── web/                  # Web-specific files
└── pubspec.yaml          # Dependencies
```

## Contributing

To contribute to the Ascenity app:

1. Familiarize yourself with the documentation
2. Follow the development workflow
3. Adhere to the code style guidelines
4. Write tests for your code
5. Update documentation as needed

## Support and Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)

---

Documentation last updated: June 2024