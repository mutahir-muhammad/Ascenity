# Custom Navigation Bar Component

The `CustomNavBar` is a core UI component in the Ascenity app, providing an animated bottom navigation experience with visual feedback and smooth transitions between application sections.

## Overview

The navigation bar is designed to be:
- Visually appealing with subtle animations
- Responsive to user interaction with haptic feedback
- Consistent with the app's design language
- Accessible with clear labels and visual indicators

## Implementation

### Class Structure

The component consists of three main classes:

1. **`CustomNavBar`**: The container component that renders the navigation bar
2. **`AnimatedNavItem`**: Individual navigation items with animation states
3. **`NavItem`**: Data model for navigation item configuration

### Features

- Smooth selection animations
- Haptic feedback on item selection
- Custom styling for selected and unselected states
- Support for both icon and label display
- Dot indicator for selected item
- Transparent background with subtle border

## Usage

```dart
CustomNavBar(
  selectedIndex: _selectedIndex,
  onTap: _onNavTapped,
  items: [
    NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home'
    ),
    NavItem(
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Journal'
    ),
    NavItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.auto_graph,
      label: 'Progress'
    ),
  ],
)
```

## Animation Details

The component uses several animations:

1. **Icon Scale Animation**: Selected icons slightly enlarge (1.1x scale)
2. **Icon Swap Animation**: Different icons for selected/unselected states
3. **Text Style Animation**: Font weight changes between 400 and 600
4. **Dot Indicator Animation**: Elastic animation for the indicator dot
5. **Color Transition Animation**: Smooth color change on selection

## Code Breakdown

### CustomNavBar

This is the container component that:
- Renders the navigation bar container with appropriate styling
- Maps through the provided items and creates AnimatedNavItem components
- Handles the item selection callback

### AnimatedNavItem

This component:
- Manages the animation controller for the dot indicator
- Handles press state and triggers haptic feedback
- Updates animations when selection state changes
- Renders the icon, label, and indicator dot

### NavItem

A simple data class that stores:
- Regular icon (for unselected state)
- Selected icon (for selected state)
- Text label

## Styling

The navigation bar adapts to both light and dark themes:

**Dark Theme**:
- Background: Deep navy blue with 95% opacity
- Border: White with 8% opacity
- Selected color: Primary theme color
- Unselected color: Surface color at 65% opacity

**Light Theme**:
- Background: White with 90% opacity
- Border: Black with 5% opacity
- Selected color: Primary theme color
- Unselected color: Surface color at 65% opacity

## Integration with Main Shell

The navigation bar is integrated with the `MainShell` component, which:
- Maintains the selected index state
- Handles page transitions via PageView
- Synchronizes page changes with navigation bar selection

## Customization Options

The component can be extended with additional features:

- Badge indicators for notifications
- Custom animations for specific items
- Middle FAB button integration
- Multiple row support for more complex layouts