import 'package:cloud_firestore/cloud_firestore.dart';

class MoodEntry {
  final String id;
  final int moodScore;
  final String moodLabel;
  final DateTime timestamp;
  final String? note;

  const MoodEntry({
    required this.id,
    required this.moodScore,
    required this.moodLabel,
    required this.timestamp,
    this.note,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      moodScore: data['moodScore'] as int,
      moodLabel: data['moodLabel'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      note: data['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moodScore': moodScore,
      'moodLabel': moodLabel,
      'timestamp': Timestamp.fromDate(timestamp),
      'note': note,
    };
  }
}