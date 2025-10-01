import 'package:cloud_firestore/cloud_firestore.dart';

class UserStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivity;
  final Map<String, int> activityByType;
  final List<String> activityDates;

  const UserStreak({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivity,
    required this.activityByType,
    required this.activityDates,
  });

  factory UserStreak.fromFirestore(DocumentSnapshot doc) {
    final dataAny = doc.data();
    final data = (dataAny is Map<String, dynamic>) ? dataAny : <String, dynamic>{};
    final last = data['lastActivity'];
    final lastDate = last is Timestamp ? last.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
    return UserStreak(
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActivity: lastDate,
      activityByType: Map<String, int>.from(data['activityByType'] ?? {}),
      activityDates: List<String>.from(data['activityDates'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'activityByType': activityByType,
      'activityDates': activityDates,
    };
  }

  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    return lastDay.isAtSameMomentAs(today);
  }

  bool get isBroken {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    return today.difference(lastDay).inDays > 1;
  }

  double get monthlyCompletionRate {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysCompleted = activityDates.where((date) {
      final activityDate = DateTime.parse(date);
      return activityDate.month == now.month && activityDate.year == now.year;
    }).length;
    return daysCompleted / daysInMonth;
  }
}