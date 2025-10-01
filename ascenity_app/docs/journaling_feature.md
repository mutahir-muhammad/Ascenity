# Journaling Feature

## Overview

The journaling feature in Ascenity allows users to record their thoughts, feelings, and experiences. It includes guided prompts, mood tracking, and sentiment analysis to help users gain insights into their emotional patterns.

## Key Components

### JournalingPage

Located at `lib/screens/journaling_page.dart`, this is the main screen for the journaling feature. It includes:

- A list of journal entries
- Tab navigation between entries and insights
- Floating action button for creating new entries
- Animated card displays for entries

```dart
class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});
  @override
  State<JournalingPage> createState() => _JournalingPageState();
}
```

### JournalDetailPage

This component handles the creation and editing of journal entries:

- Title and content input fields
- Mood selection
- Optional guided prompts
- Save functionality with sentiment analysis

```dart
class JournalDetailPage extends StatefulWidget {
  final _JournalEntry? existingEntry;
  final Function(String title, String content, String mood) onSave;
  
  const JournalDetailPage({
    super.key,
    this.existingEntry,
    required this.onSave,
  });
}
```

### JournalEntry Model

Located at `lib/models/journal_entry.dart`, this model defines the structure of journal entries:

```dart
class JournalEntry {
  final String? id;
  final String text;
  final String mood;
  final DateTime date;
  final double? sentimentScore;
  final String? sentimentLabel;
  final String? sentimentSuggestion;
  final List<String> positiveKeywords;
  final List<String> negativeKeywords;
  final String? prompt;

  // Constructor and methods...
}
```

### FirestoreService

Handles the saving and retrieval of journal entries from Firestore:

```dart
// Add a new journal entry for the current user
Future<SentimentResult> addEntry(String text, String mood, {String? prompt}) async {
  final user = _auth.currentUser;
  if (user == null) return const SentimentResult(score: 0, positiveHits: [], negativeHits: []);

  final sentiment = _sentimentService.analyze(text);
  final entry = JournalEntry(/* ... */);

  await _db
      .collection('users')
      .doc(user.uid)
      .collection('entries')
      .add(entry.toFirestore());

  return sentiment;
}
```

### SentimentService

Located at `lib/services/sentiment_service.dart`, this service performs basic sentiment analysis on journal entries:

```dart
class SentimentService {
  // Sets of positive and negative words
  static final Set<String> _positiveWords = {/* ... */};
  static final Set<String> _negativeWords = {/* ... */};

  SentimentResult analyze(String text) {
    // Analyze text for sentiment
    // Return sentiment score and keywords
  }
}
```

## User Flow

### Viewing Journal Entries

1. User navigates to the Journal tab in the main navigation
2. The JournalingPage displays existing entries in a scrollable list
3. Each entry shows:
   - Title
   - Preview of content
   - Date
   - Mood indicator

### Creating a New Entry

1. User taps the floating action button
2. JournalDetailPage opens with:
   - Optional guided prompt
   - Mood selection options
   - Title and content fields
3. User writes their entry and selects a mood
4. On save:
   - Entry is processed by SentimentService
   - Sentiment score and keywords are extracted
   - Entry is saved to Firestore via FirestoreService
   - User returns to JournalingPage with the new entry visible

### Editing an Entry

1. User taps an existing entry
2. JournalDetailPage opens with the entry's data pre-filled
3. User makes changes to the entry
4. On save, the entry is updated in Firestore

## UI Components

### JournalEntryCard

Displays a summary of a journal entry with:
- Visual mood indicator
- Title and preview of content
- Formatted date
- Touch animation

```dart
class _JournalEntryCard extends StatefulWidget {
  final _JournalEntry entry;
  final VoidCallback onTap;
  
  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
  });
}
```

### GuidedQuestionCard

Provides prompts to help users start journaling:

```dart
class _GuidedQuestionCard extends StatefulWidget {
  final Function(String) onUsePrompt;
  
  const _GuidedQuestionCard({
    required this.onUsePrompt,
  });
  
  final List<String> _questions = const [
    'What made you feel grateful today?',
    // More questions...
  ];
}
```

## Mood Selection

Users can select from a predefined list of moods:

```dart
final List<Map<String, dynamic>> _moods = [
  {'name': 'Happy', 'color': Colors.amber},
  {'name': 'Grateful', 'color': AppTheme.aquamarine},
  {'name': 'Calm', 'color': AppTheme.softBlue},
  {'name': 'Reflective', 'color': AppTheme.blueberry},
  {'name': 'Anxious', 'color': Colors.orangeAccent},
  {'name': 'Sad', 'color': Colors.blueGrey},
  {'name': 'Frustrated', 'color': Colors.redAccent},
  {'name': 'Neutral', 'color': Colors.grey},
];
```

Each mood has an associated color that is used for visual indicators.

## Sentiment Analysis

The `SentimentService` performs basic sentiment analysis on journal entries:

1. Text is processed to extract words
2. Words are compared against predefined sets of positive and negative words
3. A sentiment score is calculated based on the ratio of positive to negative words
4. The score ranges from -1.0 (very negative) to 1.0 (very positive)
5. Additional metadata is provided:
   - Sentiment label (Positive, Negative, Neutral)
   - List of positive keywords found
   - List of negative keywords found
   - A suggested action based on the sentiment

## Firestore Data Structure

Journal entries are stored in Firestore with the following structure:

```
users/{userId}/entries/{entryId}
  |- text: string
  |- mood: string
  |- date: timestamp
  |- aiSentimentScore: number
  |- aiSentimentLabel: string
  |- aiSuggestedAction: string
  |- aiPositiveHits: array<string>
  |- aiNegativeHits: array<string>
  |- prompt: string (optional)
```

## Future Enhancements

Planned improvements to the journaling feature:

1. **Rich Text Editing**: Support for formatting, images, and other media
2. **Advanced Sentiment Analysis**: More sophisticated NLP for better insights
3. **Custom Prompts**: User-created prompts based on therapeutic approaches
4. **Journal Templates**: Pre-defined templates for different journaling styles
5. **Export Options**: Ability to export journal entries as PDF or text
6. **Search and Filtering**: Better tools for finding past entries
7. **Tags and Categories**: Organization options for entries
8. **Reminders**: Scheduled notifications for journal writing