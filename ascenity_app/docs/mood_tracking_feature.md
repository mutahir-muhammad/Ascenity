# Mood Tracking Feature

## Overview

The mood tracking feature in Ascenity allows users to record and monitor their emotional states over time. It uses a visually engaging interface with animated cards, color associations, and intuitive interactions to make the process of logging moods simple and meaningful.

## Key Components

### Dashboard Integration

The mood tracking interface is prominently featured on the dashboard (`DashboardScreen`), making it easily accessible as part of the user's daily routine.

```dart
// From DashboardScreen
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling today?',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _moodController,
            itemCount: _moods.length,
            onPageChanged: _onMoodSelected,
            itemBuilder: (context, index) {
              final config = _moods[index];
              final selected = index == _currentMoodIndex;
              return _MoodCard(
                config: config, 
                selected: selected,
              );
            },
          ),
        ),
      ],
    ),
  ),
)
```

### MoodCard Component

The `_MoodCard` component displays individual mood options with visual styling and animations:

```dart
class _MoodCard extends StatefulWidget {
  final _MoodCardConfig config;
  final bool selected;
  
  const _MoodCard({
    required this.config, 
    required this.selected,
  });
}
```

Each mood card features:
- An emoji representation
- A text label
- A custom color gradient
- Selection animations

### Mood Configuration

Moods are configured with visual properties:

```dart
final List<_MoodCardConfig> _moods = const [
  _MoodCardConfig(
    label: 'Sad', 
    emoji: '😔', 
    gradient: [Color(0xFF2C2C54), Color(0xFF6C5CE7)],
    color: Color(0xFF6C5CE7),
  ),
  _MoodCardConfig(
    label: 'Calm', 
    emoji: '😐', 
    gradient: [Color(0xFF40D5FF), Color(0xFF497EFF)],
    color: Color(0xFF40D5FF),
  ),
  _MoodCardConfig(
    label: 'Happy', 
    emoji: '😄', 
    gradient: [Color(0xFF57FFBB), Color(0xFF40D5FF)],
    color: Color(0xFF57FFBB),
  ),
];
```

### Firestore Integration

Mood data is saved to Firestore through the `FirestoreService`:

```dart
Future<void> saveMoodEntry(int moodLevel, String moodLabel) async {
  final user = _auth.currentUser;
  if (user == null) return;
  await _db
      .collection('users')
      .doc(user.uid)
      .collection('moods')
      .add({
    'moodScore': moodLevel,
    'moodLabel': moodLabel,
    'timestamp': Timestamp.fromDate(DateTime.now()),
  });
}
```

### Mood Tracking Page

There is a dedicated `MoodTrackingPage` for more detailed mood tracking and visualization:

```dart
class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});
  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}
```

## User Flow

### Daily Check-in

1. User opens the app and sees the dashboard
2. The "How are you feeling today?" section is prominently displayed
3. User swipes through mood options or taps directly on a mood
4. The selected mood card scales up and provides visual feedback
5. The mood is recorded and reflected in the progress ring

### Historical Tracking

1. User navigates to the dedicated mood tracking page
2. A calendar view shows days with recorded moods
3. Charts and visualizations display mood patterns over time
4. User can view details for specific time periods

### Mood Impact

1. The app's theme can adjust based on the user's mood (via `ThemeProvider`)
2. Journal prompts may be tailored to the user's emotional state
3. Progress rings on the dashboard show mood logging completion

## UI Components

### MoodCard Animation

The mood cards feature a scale animation when selected:

```dart
AnimatedBuilder(
  animation: _scaleAnimation,
  builder: (context, child) {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            if (widget.selected) 
              BoxShadow(
                color: widget.config.color.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.config.gradient,
          ),
          border: Border.all(
            color: widget.selected 
                ? Colors.white.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.config.emoji, 
                style: const TextStyle(fontSize: 64)
              ),
              const SizedBox(height: 12),
              Text(
                widget.config.label, 
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
```

### Progress Ring

A circular progress indicator shows whether the user has logged their mood for the day:

```dart
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: progress),
  duration: const Duration(milliseconds: 1200),
  curve: Curves.easeOutCubic,
  builder: (context, value, child) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Icon(
              icon,
              size: 32,
              color: color,
            ),
          ),
        ],
      ),
    );
  },
);
```

## Data Structures

### Mood Data in Firestore

Mood entries are stored in Firestore with this structure:

```
users/{userId}/moods/{moodId}
  |- moodScore: number
  |- moodLabel: string
  |- timestamp: timestamp
```

### Local Mood Configuration

The app defines moods with these properties:

```dart
class _MoodCardConfig {
  final String label;
  final String emoji;
  final List<Color> gradient;
  final Color color;
  
  const _MoodCardConfig({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.color,
  });
}
```

## Data Analysis

### Trend Analysis

The app can analyze mood patterns over time:

```dart
// Aggregation: last 14 days mood trend counts by day
Future<List<int>> moodTrendLast14Days() async {
  final user = _auth.currentUser;
  if (user == null) return List.filled(14, 0);
  final from = DateTime.now().subtract(const Duration(days: 13));
  final snap = await _db
      .collection('users')
      .doc(user.uid)
      .collection('moods')
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(from.year, from.month, from.day)))
      .orderBy('timestamp')
      .get();
  final buckets = List.filled(14, 0);
  for (final d in snap.docs) {
    final ts = (d.data()['timestamp'] as Timestamp).toDate();
    final diff = DateTime(ts.year, ts.month, ts.day).difference(DateTime(from.year, from.month, from.day)).inDays;
    if (diff >= 0 && diff < 14) buckets[diff]++;
  }
  return buckets;
}
```

### Dashboard Snapshot

The app checks if the user has logged their mood today:

```dart
Future<({bool moodLoggedToday, bool journalLoggedToday, int longestStreak})> dashboardSnapshot() async {
  final user = _auth.currentUser;
  if (user == null) {
    return (moodLoggedToday: false, journalLoggedToday: false, longestStreak: 0);
  }
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final moodToday = await _db
      .collection('users')
      .doc(user.uid)
      .collection('moods')
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .limit(1)
      .get();
      
  // Additional queries...
  
  return (
    moodLoggedToday: moodToday.docs.isNotEmpty,
    journalLoggedToday: journalToday.docs.isNotEmpty,
    longestStreak: longest,
  );
}
```

## Theme Integration

The user's mood can influence the app's theme:

```dart
class ThemeProvider with ChangeNotifier {
  Color _themeColor = Colors.teal; // Default color

  Color get themeColor => _themeColor;

  void updateTheme(String mood) {
    _themeColor = _getColorForMood(mood);
    notifyListeners(); // This tells widgets listening to this provider to rebuild
  }

  Color _getColorForMood(String mood) {
    switch (mood) {
      case 'happy': return Colors.amber;
      case 'calm': return Colors.blue;
      case 'neutral': return Colors.grey.shade600;
      case 'sad': return Colors.indigo;
      case 'angry': return Colors.red.shade700;
      default: return Colors.teal;
    }
  }
}
```

## Future Enhancements

Planned improvements to the mood tracking feature:

1. **Extended Emotion Range**: More granular emotion options beyond basic moods
2. **Contextual Factors**: Record context such as activities, sleep quality, or stress levels
3. **Custom Moods**: Allow users to define their own mood categories
4. **Trend Analysis**: More sophisticated pattern recognition
5. **Insights and Recommendations**: AI-powered suggestions based on mood patterns
6. **Multiple Check-ins**: Support for logging moods multiple times per day
7. **Correlation Analysis**: Identify relationships between moods and journal content
8. **Trigger Identification**: Help users identify what triggers certain moods