import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_streak.dart';

class StreakService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserStreak> getUserStreak() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final doc = await _db.collection('users').doc(user.uid).get();
    return UserStreak.fromFirestore(doc);
  }

  Future<void> updateUserStreak(String activityType) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final todayStr = startOfToday.toIso8601String().split('T')[0];

    // Get current streak data
  final userRef = _db.collection('users').doc(user.uid);
  final userDoc = await userRef.get();
  final userData = userDoc.data() ?? {};

    int currentStreak = userData['currentStreak'] ?? 0;
    int longestStreak = userData['longestStreak'] ?? 0;
    DateTime? lastActivity = userData['lastActivity'] != null
        ? (userData['lastActivity'] as Timestamp).toDate()
        : null;
    Map<String, int> activityByType =
        Map<String, int>.from(userData['activityByType'] ?? {});
    List<String> activityDates =
        List<String>.from(userData['activityDates'] ?? []);

    // Update activity counts
    activityByType[activityType] = (activityByType[activityType] ?? 0) + 1;

    // Add today's date if not already recorded
    if (!activityDates.contains(todayStr)) {
      activityDates.add(todayStr);
    }

    if (lastActivity != null) {
      final startOfLastActivity =
          DateTime(lastActivity.year, lastActivity.month, lastActivity.day);
      final difference = startOfToday.difference(startOfLastActivity).inDays;

      if (difference == 1) {
        // Sequential day, increase streak
        currentStreak++;
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
      } else if (difference > 1) {
        // Streak broken
        currentStreak = 1;
      }
      // If difference is 0, it's the same day, no change to streak
    } else {
      // First activity
      currentStreak = 1;
      longestStreak = 1;
    }

    // Ensure document exists, then update
    if (!userDoc.exists) {
      await userRef.set({
        'currentStreak': 0,
        'longestStreak': 0,
        'lastActivity': null,
        'activityByType': <String, int>{},
        'activityDates': <String>[],
      }, SetOptions(merge: true));
    }

    await userRef.set({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivity': Timestamp.fromDate(today),
      'activityByType': activityByType,
      'activityDates': activityDates,
    }, SetOptions(merge: true));
  }

  Future<void> recordAchievement(String achievementId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

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

  Future<Map<String, dynamic>> getStreakStatistics() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

  final userDoc = await _db.collection('users').doc(user.uid).get();
  final userData = userDoc.data() ?? {};

    // Get activity logs for the past month
    final month = DateTime.now().subtract(const Duration(days: 30));
    final activityDates = List<String>.from(userData['activityDates'] ?? []);
    final recentDates = activityDates.where((date) {
      final activityDate = DateTime.parse(date);
      return activityDate.isAfter(month);
    }).toList();

    return {
      'currentStreak': userData['currentStreak'] ?? 0,
      'longestStreak': userData['longestStreak'] ?? 0,
      'daysActiveLastMonth': recentDates.length,
      'percentActiveLastMonth': recentDates.length / 30 * 100,
      'activityByType': Map<String, int>.from(userData['activityByType'] ?? {}),
      'lastActivity': userData['lastActivity'],
    };
  }
}