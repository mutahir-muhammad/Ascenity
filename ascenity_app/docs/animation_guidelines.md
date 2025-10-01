# Animation Guidelines for Ascenity

## Overview

Animations in Ascenity are designed to enhance the user experience by providing visual feedback, guiding attention, and creating a sense of flow. This document outlines the animation principles, patterns, and implementations used throughout the app.

## Animation Principles

### 1. Subtlety

Animations should be subtle and not distract from the core experience. They should enhance the UI rather than dominate it.

### 2. Purpose

Every animation should serve a clear purpose:
- **Feedback**: Confirming user actions
- **Continuity**: Creating a sense of connection between states
- **Guidance**: Directing user attention
- **Delight**: Adding moments of joy without being distracting

### 3. Consistency

Animation timings, curves, and behaviors should be consistent throughout the app to create a cohesive experience.

### 4. Performance

Animations should be optimized for performance, avoiding jank or excessive resource usage.

## Animation Types

### 1. Micro-interactions

Small animations that provide immediate feedback to user actions.

**Examples**:
- Button scale on press
- Ripple effects
- Toggle state changes

**Implementation**:
```dart
GestureDetector(
  onTapDown: (_) => setState(() => _isPressed = true),
  onTapUp: (_) => setState(() => _isPressed = false),
  onTapCancel: () => setState(() => _isPressed = false),
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 150),
    transform: _isPressed 
        ? (Matrix4.identity()..scale(0.95))
        : Matrix4.identity(),
    // ...
  ),
)
```

### 2. Transitions

Animations that occur when transitioning between screens or states.

**Examples**:
- Page transitions
- Modal dialogs
- Expanding cards

**Implementation**:
```dart
// Using AppRoutes utility
Navigator.of(context).push(
  AppRoutes.horizontalRoute(
    destination: DetailScreen(),
    settings: const RouteSettings(name: 'detail'),
  ),
);
```

### 3. Progress Indicators

Animations that communicate progress or loading states.

**Examples**:
- Loading spinners
- Progress rings
- Step indicators

**Implementation**:
```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progress),
  duration: const Duration(milliseconds: 1200),
  curve: Curves.easeOutCubic,
  builder: (context, value, child) {
    return CircularProgressIndicator(value: value);
  },
);
```

### 4. Decorative Animations

Animations that add visual interest or reinforce the app's theme.

**Examples**:
- Lottie animations
- Background effects
- Particle effects

**Implementation**:
```dart
Lottie.asset(
  'assets/animations/breathing_circle.json',
  width: size.width * 0.7,
  height: size.width * 0.7,
  repeat: true,
);
```

## Animation Techniques

### 1. Implicit Animations

Built-in Flutter widgets that handle animation automatically.

**Examples**:
- `AnimatedContainer`
- `AnimatedOpacity`
- `AnimatedPositioned`

### 2. Explicit Animations

Animations that provide more control through animation controllers.

**Examples**:
- `AnimationController`
- `Animation<T>`
- Custom animated widgets

**Implementation**:
```dart
class _MyAnimatedWidgetState extends State<MyAnimatedWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    // ...
  }
}
```

### 3. Hero Animations

Animations that create a connection between different screens.

**Implementation**:
```dart
Hero(
  tag: 'unique-tag-${item.id}',
  child: MyWidget(),
)
```

### 4. Staggered Animations

Sequences of animations that create a choreographed effect.

**Implementation**:
```dart
AnimationLimiter(
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 375),
        child: SlideAnimation(
          verticalOffset: 50.0,
          child: FadeInAnimation(
            child: ListItem(item: items[index]),
          ),
        ),
      );
    },
  ),
);
```

## Standard Animation Durations

- **Extra fast**: 100-150ms (micro-interactions)
- **Fast**: 200-300ms (standard transitions)
- **Medium**: 400-500ms (emphasis animations)
- **Slow**: 600-800ms (hero animations, elaborate transitions)
- **Extra slow**: 1000-1500ms (progress indicators, ambient animations)

## Animation Curves

- **Standard transitions**: `Curves.easeInOut`, `Curves.easeOut`
- **Entering elements**: `Curves.easeOutCubic`
- **Exiting elements**: `Curves.easeIn`
- **Bouncy effects**: `Curves.elasticOut` (use sparingly)
- **Natural motion**: `Curves.easeOutQuint`

## Haptic Feedback

Combine animations with haptic feedback for a multi-sensory experience:

```dart
onTap: () {
  HapticFeedback.lightImpact();
  // Trigger animation or action
},
```

## Performance Guidelines

1. **Use `RepaintBoundary`** for complex animations to isolate repainting
2. **Avoid excessive animations** on the same screen
3. **Test on lower-end devices** to ensure smooth performance
4. **Use `AnimationBuilder` pattern** for efficient rebuilds
5. **Monitor performance** using Flutter DevTools

## Examples from Ascenity

### Mood Card Animation

```dart
AnimatedBuilder(
  animation: _scaleAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: child,
    );
  },
  child: Container(
    // Mood card content
  ),
);
```

### Navigation Dot Indicator

```dart
AnimatedBuilder(
  animation: _dotScaleAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _dotScaleAnimation.value,
      child: Container(
        height: 4,
        width: 4,
        decoration: BoxDecoration(
          color: AppTheme.aquamarine,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.aquamarine.withOpacity(0.6),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  },
);
```