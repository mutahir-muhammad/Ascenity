# Ascenity Color System

This document outlines the color system used in the Ascenity application. The color system is designed to create a calm, soothing experience while maintaining accessibility and visual appeal across both light and dark themes.

## Brand Colors

### Primary Accents

| Color | Hex Code | Description | Usage |
|-------|----------|-------------|-------|
| Soft Blue | `#40D5FF` | Light blue with high saturation | Primary buttons, active states, progress indicators |
| Aquamarine | `#57FFBB` | Bright mint green | Success states, completed actions, positive elements |
| Blueberry | `#497EFF` | Deep vivid blue | Highlights, links, secondary buttons |

### Background Colors

| Color | Hex Code | Description | Usage |
|-------|----------|-------------|-------|
| Deep Navy | `#07073A` | Very dark blue, almost black | Dark mode background, depth elements |
| Light Surface | `#F4F0ED` | Off-white with warm undertone | Light mode background |

## Theme Integration

The colors are integrated into the Material Design theme via the `AppTheme` class. The theme provides:

- Light theme with `lightSurface` background
- Dark theme with `deepNavy` background
- Dynamic primary color that can be updated based on user's mood

## Color Extensions

The app uses custom color extensions to provide additional functionality:

```dart
extension ColorExtensions on Color {
  Color withValues({double? red, double? green, double? blue, double? alpha}) {
    return Color.fromARGB(
      alpha != null ? (alpha * 255).round() : this.alpha,
      red != null ? (red * 255).round() : this.red,
      green != null ? (green * 255).round() : this.green,
      blue != null ? (blue * 255).round() : this.blue,
    );
  }
}
```

This extension allows for flexible color manipulation, particularly for opacity and individual channel adjustments.

## Usage Guidelines

- Use opacity variations (`withOpacity()` or `withValues()`) for subtle effects
- Maintain sufficient contrast ratios for accessibility
- Reserve bright accent colors for important interactive elements
- Use gradients for depth and visual interest
- Apply shadows sparingly, primarily for elevation effects

## Color Mood Associations

The app associates colors with emotional states to enhance the mood tracking experience:

| Mood | Primary Color | Purpose |
|------|--------------|---------|
| Happy | Amber/Yellow | Represents joy and energy |
| Calm | Soft Blue | Represents peace and tranquility |
| Sad | Indigo/Purple | Represents melancholy and reflection |
| Anxious | Orange | Represents alertness and tension |
| Neutral | Gray | Represents balance and neutrality |

## Implementation Example

```dart
// Button with primary color
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.softBlue,
    foregroundColor: Colors.white,
  ),
  onPressed: () {},
  child: Text('Primary Action'),
)

// Container with gradient
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [AppTheme.softBlue, AppTheme.aquamarine],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: child,
)

// Text with opacity
Text(
  'Secondary information',
  style: TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
  ),
)
```