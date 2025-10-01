# Ascenity Architecture Documentation

## Overview

Ascenity follows a clean, modular architecture that separates concerns and promotes maintainable code. This document outlines the architectural approach, key components, and design patterns used throughout the application.

## Architecture Layers

The application is divided into three primary layers:

### 1. Presentation Layer

**Purpose**: Handle UI rendering and user interaction

**Key Components**:
- **Screens**: Full-page UI components (e.g., `DashboardScreen`, `JournalingPage`)
- **Widgets**: Reusable UI components (e.g., `CustomNavBar`, `AnimatedButton`)
- **Theme**: Visual styling and design system via `AppTheme`

**State Management**:
- Local widget state for UI-specific state
- Provider pattern for shared application state

### 2. Business Logic Layer

**Purpose**: Implement core application logic and handle data operations

**Key Components**:
- **Services**: Handle business logic and external interactions (e.g., `AuthService`, `FirestoreService`)
- **Providers**: Manage application state and notify listeners of changes (e.g., `ThemeProvider`)
- **Utils**: Utility functions and helpers (e.g., `AppRoutes`)

### 3. Data Layer

**Purpose**: Handle data storage, retrieval, and transformation

**Key Components**:
- **Models**: Data structures that define application entities (e.g., `JournalEntry`)
- **Repositories**: Abstract data sources (implemented via services)
- **External APIs**: Firebase services and other external data providers

## Key Design Patterns

### Provider Pattern

The app uses the Provider pattern for state management, which allows:
- Widgets to consume and respond to state changes
- Separation of UI and business logic
- Testable, isolated components

Example:
```dart
return ChangeNotifierProvider(
  create: (_) => ThemeProvider(),
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) {
      return MaterialApp(
        theme: AppTheme.lightTheme(themeProvider.themeColor),
        darkTheme: AppTheme.darkTheme(themeProvider.themeColor),
        // ...
      );
    },
  ),
);
```

### Repository Pattern

Though not explicitly named as repositories, services like `FirestoreService` implement the repository pattern by:
- Abstracting data sources
- Providing a clean API for data operations
- Handling data transformation between app models and external formats

### Factory Pattern

Used in utility classes like `AppRoutes` to create different types of routes:
```dart
static Route<T> heroRoute<T>({ /* ... */ }) {
  // Create and return a route with hero-like transition
}

static Route<T> modalRoute<T>({ /* ... */ }) {
  // Create and return a route with modal-like transition
}
```

## Authentication Flow

1. User launches app
2. `main.dart` initializes Firebase
3. `MyApp` checks if user has seen onboarding
4. If onboarding completed, `AuthGate` renders
5. `AuthGate` listens to Firebase auth state changes
6. User is directed to `LoginScreen` or `MainShell` based on auth state

```
App Launch → Firebase Init → Onboarding Check → AuthGate → LoginScreen/MainShell
```

## Navigation Structure

The app uses a nested navigation structure:

1. **Root Navigation**: Handled by `MaterialApp` for global navigation
2. **Authentication Flow**: Managed by `AuthGate` for login/logout transitions
3. **Main App Flow**: Managed by `MainShell` with `PageView` and `CustomNavBar`
4. **Detail Navigation**: Individual screens handle their internal navigation

## Data Flow

1. **User Interaction**: UI events are captured in screen/widget classes
2. **Business Logic**: Services process the interactions and perform operations
3. **Data Storage**: Firebase services persist data to the cloud
4. **UI Updates**: Streams or callbacks update the UI with new data

## Dependency Injection

The app uses a simple form of dependency injection:
- Services are instantiated within the components that need them
- Future versions could implement a more robust DI system

## Error Handling

- Firebase errors are caught and processed in service classes
- UI feedback is provided for critical errors
- Debug logs are generated in development for troubleshooting

## Future Architecture Enhancements

1. **Bloc Pattern**: Consider implementing BLoC for more complex state management
2. **Dependency Injection**: Add a proper DI framework as the app grows
3. **Clean Architecture**: Further separate layers with interfaces and implementations
4. **Offline Support**: Implement local persistence for offline functionality
5. **Feature Modules**: Organize code into feature-based modules