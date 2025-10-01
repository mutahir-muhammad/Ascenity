# Ascenity – Comprehensive Development History

## Initial Development (September 2025)

### Core Architecture & Initial Setup
- **Firebase Integration**: Initialized Firebase Core, Auth, and Firestore for backend services
- **State Management**: Implemented Provider pattern with MultiProvider root
- **Navigation**: Custom navigation with PageView and custom bottom navigation bar
- **Authentication**: Implemented Firebase Authentication with email and Google Sign-in
- **Project Structure**: Organized into screens, widgets, services, providers, and design directories
- **Base Dependencies**: Added google_fonts, animations, flutter_staggered_animations, fl_chart, lottie, shimmer packages

### Feature Development

#### Authentication & User Management
- Created AuthGate widget for handling auth state changes
- Implemented LoginScreen with email/password and Google Sign-in options
- Added user profile data storage in Firestore
- Implemented secure authentication flows and credential validation

#### Home Experience (Dashboard)
- Designed collapsing SliverAppBar with greeting and user avatar
- Created MoodSelectorCarousel with PageView and mood card animations
- Implemented mood tracking with Firestore persistence
- Added ProgressRings with TweenAnimationBuilder for daily progress tracking
- Built QuickActionsGrid with staggered animations and micro-interactions

#### Journaling System
- Created JournalingPage with staggered list animations and search capability
- Implemented JournalDetailPage with guided prompts and mood selection
- Added journal entry persistence with Firebase
- Created hero transitions between list and detail views
- Implemented GuidedQuestionCard with swipe-to-dismiss gesture

#### Progress & Streaks
- Built comprehensive StreaksScreen with animated statistics
- Created MoodTrendChart with animated line drawing
- Implemented ReflectionChart for weekly activity visualization
- Added unlockable achievement badges with cross-fade animations
- Implemented streak calculation logic with Firebase persistence
- Added shimmer effects and confetti animations for celebrations

#### AI Insights
- Created AI Insights modal bottom sheet with staggered animations
- Implemented sentiment analysis cards and word cloud visualization
- Added suggested journaling prompts based on past entries

## Major Update (2025-10-01) — Theme System & UX Refinement

### Comprehensive Theme System
- **Design Tokens**: Created systematic design tokens system in tokens.dart
  - Defined palette: Oxford Blue (#0A2239), Honolulu Blue (#027BCE), Robin Egg Blue (#1CCAD8), Emerald (#00D37D), Snow (#FCF7F8)
  - Added darkSurface (#1E2A47) and lightShadow (#DDE5ED) tokens
  - Created consistent spacing and radius tokens

- **Typography System**:
  - Applied Manrope as primary font via GoogleFonts
  - Retained Poppins for selected headlines
  - Established consistent text style hierarchy

- **ThemeProvider**:
  - Created light/dark theme variants with ColorScheme.fromSeed
  - Mapped palette colors to semantic roles (primary/secondary/tertiary)
  - Implemented theme persistence with SharedPreferences
  - Added global SharedAxis transitions in PageTransitionsTheme

### Feature Enhancements

- **Onboarding Experience**:
  - Created animated onboarding with Lottie breathing animation
  - Added staggered text reveal animations and "breathing" Get Started button
  - Implemented onboarding completion persistence
  - Used Honolulu Blue to Robin Egg Blue gradient for background

- **Navigation & Transitions**:
  - Created SharedAxisPageRoute wrapper for consistent transitions
  - Customized transition types per navigation context:
    - Horizontal for wizard-like flows
    - Vertical for hierarchical navigation
    - Scaled for modal-style transitions

- **Dashboard Improvements**:
  - Unified all gradients and colors to use theme tokens
  - Fixed background gradient to use theme colors
  - Updated mood cards to use semantic color roles
  - Ensured all progress indicators use correct theme colors

- **Settings Page**:
  - Added comprehensive settings page with user profile display
  - Implemented dark mode toggle with persistence
  - Added sign out functionality and app version display
  - Created smooth transitions and tactile feedback

- **Meditate Feature**:
  - Implemented new MeditateScreen with breathing visualization
  - Created pulsing radial gradient animation with theme colors
  - Added inhale/exhale indicators and haptic feedback
  - Implemented pause/resume functionality

- **Streaks & Progress**:
  - Updated charts to use primary→secondary gradients with tertiary accents
  - Implemented AnimatedSwitcher for badge icon state transitions
  - Enhanced shimmer effects on streak header
  - Retained and improved confetti animations

- **Journaling Experience**:
  - Removed legacy AppTheme references
  - Updated guided prompt gradients to use theme colors
  - Ensured consistent animations and transitions
  - Fixed Theme usage in field initializers

### Technical Improvements
- Optimized animation performance across the app
- Fixed constructor signatures for private widgets
- Removed legacy purple tints and AppTheme references
- Standardized gesture handling and haptic feedback
- Ensured consistent shadows and elevation across components
- Fixed ThemeData/CardTheme type mismatches
- Hardened streak logic with defensive programming

## Current Status (October 1, 2025)

- **Status**: The app compiles successfully with no analyzer errors.
- **UI Compliance**: All UI elements align with the design specification.
- **Animation**: All specified animations and transitions are implemented.
- **Theme**: Dark and light modes properly implemented with correct palette allocation.
- **Persistence**: Theme choice, onboarding status, and user data persist correctly.
- **Features**: All core features (mood tracking, journaling, progress/streaks, AI insights, breathing) are functional.

### Next Steps
- Further optimize performance for low-end devices
- Add more unit and widget tests for core functionality
- Consider implementing additional guided meditation flows
- Expand AI insights capabilities with more visualization options
