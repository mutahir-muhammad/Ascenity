// lib/screens/add_entry_screen.dart
import 'package:flutter/material.dart';
import 'package:ascenity_app/services/firestore_services.dart';
import 'package:provider/provider.dart';
import 'package:ascenity_app/providers/theme_provider.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedMood = 'neutral'; // Default mood
  bool _isLoading = false;

  final List<String> _moods = ['happy', 'calm', 'neutral', 'sad', 'angry'];

  void _saveEntry() async {
    if (_textController.text.isEmpty) return;

    setState(() { _isLoading = true; });

    final sentiment = await _firestoreService.addEntry(_textController.text, _selectedMood);

    if (mounted) {
      setState(() { _isLoading = false; });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Journal saved (${sentiment.label})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('How are you feeling today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: _moods.map((mood) {
                        final bool selected = _selectedMood == mood;
                        final emoji = _emojiForMood(mood);
                        return GestureDetector(
                          onTap: () {
                            setState(() { _selectedMood = mood; });
                            Provider.of<ThemeProvider>(context, listen: false).updateThemeForMood(mood);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(mood[0].toUpperCase() + mood.substring(1)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                    decoration: const InputDecoration(
                      hintText: 'Write about your day...\n(Your entries are private)',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
                : ElevatedButton.icon(
                    onPressed: _saveEntry,
                    icon: const Icon(Icons.check),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14.0),
                      child: Text('Save Entry', style: TextStyle(fontSize: 16)),
                    ),
                  ),
          ],
        ),
      ),
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