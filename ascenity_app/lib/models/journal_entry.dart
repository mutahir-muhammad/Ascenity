// lib/models/journal_entry.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String? id; // The document ID from Firestore
  final String text;
  final String mood;
  final DateTime date;
  final double? sentimentScore;
  final String? sentimentLabel;
  final String? sentimentSuggestion;
  final List<String> positiveKeywords;
  final List<String> negativeKeywords;
  final String? prompt;

  JournalEntry({
    this.id,
    required this.text,
    required this.mood,
    required this.date,
    this.sentimentScore,
    this.sentimentLabel,
    this.sentimentSuggestion,
    this.positiveKeywords = const [],
    this.negativeKeywords = const [],
    this.prompt,
  });

  // Converts a Firestore DocumentSnapshot into a JournalEntry object
  factory JournalEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    return JournalEntry(
      id: doc.id,
      text: data['text'],
      mood: data['mood'],
      date: (data['date'] as Timestamp).toDate(),
      sentimentScore: (data['aiSentimentScore'] as num?)?.toDouble(),
      sentimentLabel: data['aiSentimentLabel'],
      sentimentSuggestion: data['aiSuggestedAction'],
      positiveKeywords: (data['aiPositiveHits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      negativeKeywords: (data['aiNegativeHits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      prompt: data['prompt'],
    );
  }

  // Converts a JournalEntry object into a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'mood': mood,
      'date': Timestamp.fromDate(date),
      if (sentimentScore != null) 'aiSentimentScore': sentimentScore,
      if (sentimentLabel != null) 'aiSentimentLabel': sentimentLabel,
      if (sentimentSuggestion != null) 'aiSuggestedAction': sentimentSuggestion,
      if (positiveKeywords.isNotEmpty) 'aiPositiveHits': positiveKeywords,
      if (negativeKeywords.isNotEmpty) 'aiNegativeHits': negativeKeywords,
      if (prompt != null && prompt!.isNotEmpty) 'prompt': prompt,
    };
  }
}