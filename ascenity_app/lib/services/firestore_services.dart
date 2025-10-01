// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ascenity_app/models/journal_entry.dart';
import 'package:ascenity_app/services/sentiment_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SentimentService _sentimentService = SentimentService();

  // Add a new journal entry for the current user
  Future<SentimentResult> addEntry(String text, String mood, {String? prompt}) async {
    final user = _auth.currentUser;
    if (user == null) return const SentimentResult(score: 0, positiveHits: [], negativeHits: []);

    final sentiment = _sentimentService.analyze(text);
    final entry = JournalEntry(
      text: text,
      mood: mood,
      date: DateTime.now(),
      sentimentScore: sentiment.score,
      sentimentLabel: sentiment.label,
      sentimentSuggestion: sentiment.suggestion,
      positiveKeywords: sentiment.positiveHits,
      negativeKeywords: sentiment.negativeHits,
      prompt: prompt,
    );

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .add(entry.toFirestore());

    return sentiment;
  }

  // Get a stream of journal entries for the current user
  Stream<List<JournalEntry>> getEntriesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]); // Return an empty stream if no user
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .orderBy('date', descending: true) // Show newest entries first
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntry.fromFirestore(doc))
            .toList());
  }

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

  // Aggregation: last 14 days mood trend counts by day (from moods collection)
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

  // Aggregation: weekly reflections count for last 7 days
  Future<List<int>> weeklyReflectionsCount() async {
    final user = _auth.currentUser;
    if (user == null) return List.filled(7, 0);
    final from = DateTime.now().subtract(const Duration(days: 6));
    final snap = await _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(from.year, from.month, from.day)))
        .orderBy('date')
        .get();
    final buckets = List.filled(7, 0);
    for (final d in snap.docs) {
      final ts = (d.data()['date'] as Timestamp).toDate();
      final diff = DateTime(ts.year, ts.month, ts.day).difference(DateTime(from.year, from.month, from.day)).inDays;
      if (diff >= 0 && diff < 7) buckets[diff]++;
    }
    return buckets;
  }

  // Simple streak: count consecutive days with at least one entry up to today
  Future<int> currentStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .orderBy('date', descending: true)
        .limit(60)
        .get();
    int streak = 0;
    DateTime cursor = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final daysWithEntry = <DateTime>{};
    for (final d in snap.docs) {
      final ts = (d.data()['date'] as Timestamp).toDate();
      daysWithEntry.add(DateTime(ts.year, ts.month, ts.day));
    }
    while (daysWithEntry.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<int> longestStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;
    final snap = await _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .orderBy('date', descending: true)
        .limit(365)
        .get();
    if (snap.docs.isEmpty) return 0;
    final daysWithEntry = snap.docs
        .map((d) => (d.data()['date'] as Timestamp).toDate())
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort();
    if (daysWithEntry.isEmpty) return 0;
    int best = 1;
    int current = 1;
    for (var i = 1; i < daysWithEntry.length; i++) {
      final prev = daysWithEntry[i - 1];
      final currentDay = daysWithEntry[i];
      if (currentDay.difference(prev).inDays == 1) {
        current++;
      } else {
        best = best < current ? current : best;
        current = 1;
      }
    }
    best = best < current ? current : best;
    return best;
  }

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
    final journalToday = await _db
        .collection('users')
        .doc(user.uid)
        .collection('entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .limit(1)
        .get();
    final longest = await longestStreak();
    return (
      moodLoggedToday: moodToday.docs.isNotEmpty,
      journalLoggedToday: journalToday.docs.isNotEmpty,
      longestStreak: longest,
    );
  }
}