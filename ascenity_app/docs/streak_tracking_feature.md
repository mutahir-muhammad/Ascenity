# Streak Tracking Feature

## Overview

The streak tracking feature in Ascenity encourages user engagement by tracking consecutive days of app usage. It visually represents a user's daily check-ins and rewards consistent usage, promoting habit formation for mental wellness activities.

## Key Components

### Streak Counter

The streak counter displays the user's current streak and is prominently featured on the dashboard:

```dart
// From DashboardScreen
Card(
  elevation: 4,
  shadowColor: Colors.black26,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_fire_department,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Streak',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${streakData.currentStreak} days',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ],
    ),
  ),
)
```

### Firestore Integration

Streak data is managed through the `FirestoreService`:

```dart
Future<void> updateUserStreak() async {
  final user = _auth.currentUser;
  if (user == null) return;
  
  final today = DateTime.now();
  final startOfToday = DateTime(today.year, today.month, today.day);
  
  // Get user streak data
  final userDoc = await _db.collection('users').doc(user.uid).get();
  final userData = userDoc.data() ?? {};
  
  // Default values if no streak data exists
  int currentStreak = userData['currentStreak'] ?? 0;
  int longestStreak = userData['longestStreak'] ?? 0;
  DateTime? lastActivity = userData['lastActivity'] != null 
      ? (userData['lastActivity'] as Timestamp).toDate() 
      : null;
  
  if (lastActivity != null) {
    final startOfLastActivity = DateTime(
      lastActivity.year, 
      lastActivity.month, 
      lastActivity.day
    );
    
    final difference = startOfToday.difference(startOfLastActivity).inDays;
    
    if (difference == 1) {
      // Sequential day, increase streak
      currentStreak++;
      // Update longest streak if needed
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else if (difference > 1) {
      // Streak broken
      currentStreak = 1;
    } else if (difference == 0) {
      // Same day, no change to streak
      return;
    }
  } else {
    // First activity
    currentStreak = 1;
    longestStreak = 1;
  }
  
  // Update user document
  await _db.collection('users').doc(user.uid).update({
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastActivity': Timestamp.fromDate(today),
  });
}
```

### Streak Model

A Dart class encapsulates streak data for easier manipulation:

```dart
class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;
  
  const UserStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivity,
  });
  
  factory UserStreak.fromMap(Map<String, dynamic> map) {
    return UserStreak(
      currentStreak: map['currentStreak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      lastActivity: map['lastActivity'] != null 
          ? (map['lastActivity'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }
  
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActivity.year, 
      lastActivity.month, 
      lastActivity.day
    );
    return lastDay.isAtSameMomentAs(today);
  }
  
  bool get isBroken {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActivity.year, 
      lastActivity.month, 
      lastActivity.day
    );
    return today.difference(lastDay).inDays > 1;
  }
}
```

## User Flow

### Daily Check-in

1. User opens the app and completes one of these actions:
   - Records their mood
   - Creates a journal entry
   - Completes a guided meditation
   - Engages with any tracked feature

2. The app automatically:
   - Updates the lastActivity timestamp
   - Calculates the current streak
   - Updates the longest streak if necessary
   - Displays the updated streak on the dashboard

### Streak Details

1. User taps on the streak card
2. A detailed view opens showing:
   - Current streak
   - Longest streak achieved
   - Calendar view of activity days
   - Percentage of days active in current month

### Streak Milestones

1. User reaches a streak milestone (7, 30, 90 days)
2. The app displays a congratulatory animation
3. User receives a notification of their achievement
4. Achievement is recorded in user profile

## UI Components

### Streak Card

The streak card on the dashboard shows the current streak with a flame icon:

```dart
Card(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  elevation: 2,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Streak',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(Icons.local_fire_department, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedCounter(
          count: streakCount,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'days',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    ),
  ),
),
```

### Calendar Visualization

A calendar view visualizes the user's activity streak:

```dart
SizedBox(
  height: 300,
  child: PageView(
    controller: _calendarController,
    onPageChanged: (index) {
      setState(() {
        _currentMonth = DateTime(
          DateTime.now().year,
          DateTime.now().month - (_currentMonthIndex - index),
        );
      });
    },
    children: List.generate(3, (index) {
      final month = DateTime(
        DateTime.now().year,
        DateTime.now().month - (1 - index),
      );
      return _buildMonthCalendar(month);
    }),
  ),
)

Widget _buildMonthCalendar(DateTime month) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat.yMMMM().format(month),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Expanded(
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _daysInMonth(month) + _firstDayOfMonth(month),
          itemBuilder: (context, index) {
            if (index < _firstDayOfMonth(month)) {
              return Container();
            }
            final day = index - _firstDayOfMonth(month) + 1;
            final date = DateTime(month.year, month.month, day);
            final hasActivity = _activityDays.contains(
              DateFormat('yyyy-MM-dd').format(date)
            );
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: hasActivity 
                    ? Theme.of(context).primaryColor.withOpacity(0.2) 
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: date.isAtSameMomentAs(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day
                ))
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: GoogleFonts.poppins(
                    color: hasActivity 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    fontWeight: hasActivity ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
```

### Streak Milestone Animation

When a user reaches a milestone, a celebration animation is played:

```dart
void _checkAndCelebrateStreak(int streakCount) {
  final milestones = [7, 14, 21, 30, 60, 90, 180, 365];
  if (milestones.contains(streakCount)) {
    // Show celebration
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/celebration.json',
                height: 150,
                repeat: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You've maintained a $streakCount-day streak!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, 
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Record the achievement
    _firestore.recordAchievement('streak_$streakCount');
  }
}
```

## Data Structures

### Streak Data in Firestore

User streak data is stored directly in the user document:

```
users/{userId}
  |- currentStreak: number
  |- longestStreak: number
  |- lastActivity: timestamp
```

Additionally, activity logs are stored in a subcollection:

```
users/{userId}/activity/{activityId}
  |- date: timestamp
  |- type: string (mood, journal, meditation)
```

### Activity Log Model

```dart
class ActivityLog {
  final String id;
  final DateTime date;
  final String type;
  final String? details;
  
  const ActivityLog({
    required this.id,
    required this.date,
    required this.type,
    this.details,
  });
  
  factory ActivityLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] as String,
      details: data['details'] as String?,
    );
  }
}
```

## Data Analysis

### Streak Statistics

The app calculates various streak statistics:

```dart
Future<Map<String, dynamic>> getStreakStatistics() async {
  final user = _auth.currentUser;
  if (user == null) return {};
  
  final userDoc = await _db.collection('users').doc(user.uid).get();
  final userData = userDoc.data() ?? {};
  
  // Get activity logs for the past month
  final month = DateTime.now().subtract(const Duration(days: 30));
  final activitySnap = await _db
      .collection('users')
      .doc(user.uid)
      .collection('activity')
      .where('date', isGreaterThan: Timestamp.fromDate(month))
      .orderBy('date')
      .get();
  
  // Calculate statistics
  final activityDays = <String>{};
  final activityByType = <String, int>{};
  
  for (final doc in activitySnap.docs) {
    final data = doc.data();
    final date = (data['date'] as Timestamp).toDate();
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    activityDays.add(dateStr);
    
    final type = data['type'] as String;
    activityByType[type] = (activityByType[type] ?? 0) + 1;
  }
  
  return {
    'currentStreak': userData['currentStreak'] ?? 0,
    'longestStreak': userData['longestStreak'] ?? 0,
    'daysActiveLastMonth': activityDays.length,
    'percentActiveLastMonth': activityDays.length / 30 * 100,
    'activityByType': activityByType,
    'lastActivity': userData['lastActivity'],
  };
}
```

## Gamification

### Achievements

The app rewards streak milestones with achievements:

```dart
Future<void> recordAchievement(String achievementId) async {
  final user = _auth.currentUser;
  if (user == null) return;
  
  await _db
      .collection('users')
      .doc(user.uid)
      .collection('achievements')
      .doc(achievementId)
      .set({
    'achievedAt': Timestamp.fromDate(DateTime.now()),
    'type': achievementId,
  });
}
```

### Achievement Display

Achievements are displayed in the user profile:

```dart
StreamBuilder<QuerySnapshot>(
  stream: _db
      .collection('users')
      .doc(user.uid)
      .collection('achievements')
      .orderBy('achievedAt', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final achievements = snapshot.data!.docs;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        final type = achievement['type'] as String;
        
        return _buildAchievementCard(type);
      },
    );
  },
)
```

## Future Enhancements

Planned improvements to the streak tracking feature:

1. **Weekly Goals**: Set weekly activity goals in addition to daily streaks
2. **Recovery Mechanic**: Allow users to "repair" a broken streak once per month
3. **Streak Challenges**: Time-limited challenges with specific activity requirements
4. **Social Sharing**: Option to share streak milestones on social media
5. **Advanced Analytics**: More detailed visualizations of streak data
6. **Activity Weights**: Different activities could count differently toward streak maintenance
7. **Multiple Streak Types**: Track different streaks for different activities (journaling streak vs meditation streak)
8. **Adaptive Reminders**: Send reminders based on user's typical usage patterns to maintain streaks