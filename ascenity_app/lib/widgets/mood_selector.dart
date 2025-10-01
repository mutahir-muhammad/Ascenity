import 'package:flutter/material.dart';
import 'package:ascenity_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

typedef MoodChanged = void Function(String mood);

class MoodSelector extends StatelessWidget {
  final String selected;
  final MoodChanged onChanged;
  final List<String> moods;

  const MoodSelector({super.key, required this.selected, required this.onChanged, this.moods = const ['happy','calm','neutral','sad','angry']});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: moods.map((mood) {
        final bool isSelected = selected == mood;
        return GestureDetector(
          onTap: () {
            onChanged(mood);
            Provider.of<ThemeProvider>(context, listen: false).updateThemeForMood(mood);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_emojiForMood(mood), style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(mood[0].toUpperCase() + mood.substring(1)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _emojiForMood(String mood) {
    switch (mood) {
      case 'happy': return '😊';
      case 'calm': return '😌';
      case 'neutral': return '😐';
      case 'sad': return '😢';
      case 'angry': return '😠';
      default: return '🙂';
    }
  }
}
