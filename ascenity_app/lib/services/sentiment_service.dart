import 'dart:math';

class SentimentResult {
  final double score;
  final List<String> positiveHits;
  final List<String> negativeHits;

  const SentimentResult({required this.score, required this.positiveHits, required this.negativeHits});

  String get label {
    if (score >= 0.25) return 'Positive';
    if (score <= -0.25) return 'Negative';
    return 'Neutral';
  }

  String get suggestion {
    switch (label) {
      case 'Positive':
        return 'You seem to be feeling great! Take a moment to savor this energy or share it with someone you care about.';
      case 'Negative':
        return 'It sounds like today has been heavy. Try a short breathing exercise or reach out to a friend for support.';
      default:
        return 'You are in a balanced place. Consider a gentle stretch or a gratitude note to keep the momentum.';
    }
  }
}

class SentimentService {
  static final Set<String> _positiveWords = {
    'calm', 'peace', 'happy', 'joy', 'smile', 'grateful', 'excited', 'love', 'proud', 'serene',
    'encouraged', 'rested', 'refreshed', 'energized', 'hopeful', 'optimistic', 'satisfied', 'relaxed', 'thankful', 'strong',
  };

  static final Set<String> _negativeWords = {
    'sad', 'angry', 'anxious', 'stressed', 'tired', 'worried', 'overwhelmed', 'upset', 'lonely', 'frustrated',
    'drained', 'exhausted', 'rough', 'bad', 'nervous', 'guilty', 'fear', 'afraid', 'burned', 'down',
  };

  SentimentResult analyze(String text) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z\s]"), ' ')
        .split(RegExp(r"\s+"))
        .where((word) => word.isNotEmpty)
        .toList();

    final positiveHits = <String>[];
    final negativeHits = <String>[];

    for (final word in words) {
      if (_positiveWords.contains(word)) positiveHits.add(word);
      if (_negativeWords.contains(word)) negativeHits.add(word);
    }

    final totalMatches = max(1, positiveHits.length + negativeHits.length);
    final score = (positiveHits.length - negativeHits.length) / totalMatches;

    return SentimentResult(
      score: score.clamp(-1.0, 1.0),
      positiveHits: positiveHits,
      negativeHits: negativeHits,
    );
  }
}
