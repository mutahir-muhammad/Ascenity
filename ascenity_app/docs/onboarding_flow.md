# Onboarding Flow

## Overview

The onboarding flow in Ascenity provides new users with an introduction to the app's purpose and functionality. It's designed to be visually engaging, informative, and quick to complete, ensuring users understand the value proposition without friction.

## Flow Structure

The onboarding process follows this sequence:

1. **Splash Screen** (implicit) - App loading and initialization
2. **Onboarding Screen** - Visual introduction with animation and key messaging
3. **Auth Gate** - Authentication check to direct users to login or main app
4. **Login Screen** - Google authentication option
5. **Main Shell** - Entry into the main application flow

## Implementation Details

### Onboarding Screen

Located at `lib/screens/onboarding_screen.dart`, this screen features:

- Lottie animation for visual appeal
- Fade and slide animations for text elements
- A "Get Started" button with haptic feedback
- Persistent state management using SharedPreferences

```dart
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const OnboardingScreen({super.key, required this.onGetStarted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
```

Key elements:

1. **Animation Controller**: Manages animations for content elements
   ```dart
   _controller = AnimationController(
     duration: const Duration(seconds: 2),
     vsync: this,
   );
   ```

2. **Get Started Button**: Triggers completion of onboarding
   ```dart
   Future<void> _handleGetStarted() async {
     HapticFeedback.mediumImpact();
     // Save onboarding completed flag
     final prefs = await SharedPreferences.getInstance();
     await prefs.setBool('seen_onboarding', true);
     
     if (mounted) {
       widget.onGetStarted();
     }
   }
   ```

3. **Persistence**: The onboarding state is saved to local storage

### Main App Entry Point

In `lib/main.dart`, the app checks if the user has already seen the onboarding:

```dart
class _MyAppState extends State<MyApp> {
  bool _seenOnboarding = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      _loadingPrefs = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ...
      home: _loadingPrefs
          ? const SizedBox.shrink()
          : _seenOnboarding
              ? const AuthGate()
              : OnboardingScreen(
                  onGetStarted: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AuthGate()),
                    );
                  },
                ),
    );
  }
}
```

## Visual Design Elements

The onboarding screen uses:

1. **Gradient Background**: A soothing blend of app theme colors
   ```dart
   decoration: const BoxDecoration(
     gradient: LinearGradient(
       begin: Alignment.topLeft,
       end: Alignment.bottomRight,
       colors: [AppTheme.softBlue, AppTheme.aquamarine],
     ),
   ),
   ```

2. **Animated Illustration**: A Lottie animation representing mindfulness
   ```dart
   Lottie.asset(
     'assets/animations/breathing_circle.json',
     width: size.width * 0.7,
     height: size.width * 0.7,
     repeat: true,
   ),
   ```

3. **Value Proposition**: Clear messaging about the app's purpose
   ```dart
   Text(
     "Know your mind,\nknow your emotions.",
     textAlign: TextAlign.center,
     style: GoogleFonts.poppins(
       fontSize: 26,
       fontWeight: FontWeight.w600,
       color: Colors.white,
       // ...
     ),
   ),
   ```

## Animation Details

The onboarding screen uses several animations to create an engaging experience:

1. **Breathing Animation**: A Lottie animation that subtly scales
   ```dart
   AnimatedBuilder(
     animation: _controller,
     builder: (context, child) {
       return Transform.scale(
         scale: _scaleAnimation.value,
         child: child,
       );
     },
     // ...
   ),
   ```

2. **Text Fade-In**: Content text fades in and slides up
   ```dart
   FadeTransition(
     opacity: _fadeAnimation,
     child: SlideTransition(
       position: _slideAnimation,
       child: Text(
         // ...
       ),
     ),
   ),
   ```

3. **Button Press Animation**: The "Get Started" button responds to touch
   ```dart
   AnimatedContainer(
     duration: const Duration(milliseconds: 150),
     curve: Curves.easeOut,
     transform: _isButtonPressed
         ? (Matrix4.identity()..scale(0.95))
         : Matrix4.identity(),
     // ...
   ),
   ```

## Flow to Authentication

When the user completes onboarding by tapping "Get Started":

1. The onboarding completion state is saved to `SharedPreferences`
2. The app navigates to the `AuthGate` widget
3. `AuthGate` checks for an authenticated user
4. If not authenticated, the `LoginScreen` is shown
5. After successful login, the user enters the main app via `MainShell`

## Testing the Onboarding Flow

To test the onboarding flow during development:

1. **Reset onboarding state**:
   ```dart
   SharedPreferences prefs = await SharedPreferences.getInstance();
   await prefs.setBool('seen_onboarding', false);
   ```

2. **Force showing onboarding**:
   ```dart
   Navigator.of(context).pushReplacement(
     MaterialPageRoute(
       builder: (_) => OnboardingScreen(
         onGetStarted: () {
           Navigator.of(context).pushReplacement(
             MaterialPageRoute(builder: (_) => const AuthGate()),
           );
         },
       ),
     ),
   );
   ```

## Enhancement Opportunities

Potential improvements to the onboarding flow:

1. **Multiple Screens**: Expand to multiple screens showing different features
2. **Skippable Flow**: Add option to skip onboarding
3. **Interactive Elements**: Add interactive demonstrations of key features
4. **Personalization**: Collect initial preferences to personalize the experience
5. **Progress Indicator**: Show progress through multiple onboarding screens