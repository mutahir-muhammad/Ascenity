import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/mood_entry.dart';

class MoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveMoodEntry({
    required int moodScore,
    required String moodLabel,
    String? note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final moodEntry = MoodEntry(
      id: '', // Will be set by Firestore
      moodScore: moodScore,
      moodLabel: moodLabel,
      timestamp: DateTime.now(),
      note: note,
    );

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .add(moodEntry.toMap());
  }

  Future<List<MoodEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    var query = _db
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true);

    if (startDate != null) {
      query = query.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map((doc) => MoodEntry.fromFirestore(doc))
        .toList();
  }

  Future<MoodEntry?> getTodaysMoodEntry() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _db
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;
    return MoodEntry.fromFirestore(querySnapshot.docs.first);
  }

  Future<Map<String, double>> getMoodAverages({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final entries = await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );

    if (entries.isEmpty) return {};

    final moodCounts = <String, int>{};
    final moodScores = <String, int>{};

    for (final entry in entries) {
      moodCounts[entry.moodLabel] = (moodCounts[entry.moodLabel] ?? 0) + 1;
      moodScores[entry.moodLabel] =
          (moodScores[entry.moodLabel] ?? 0) + entry.moodScore;
    }

    return moodCounts.map((label, count) {
      final average = moodScores[label]! / count;
      return MapEntry(label, average);
    });
  }

  Stream<List<MoodEntry>> streamMoodEntries() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('moods')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MoodEntry.fromFirestore(doc)).toList());
  }
}