// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:ascenity_app/models/journal_entry.dart';
import 'package:ascenity_app/screens/add_entry_screens.dart';
import 'package:ascenity_app/services/auth_service.dart';
import 'package:ascenity_app/services/firestore_services.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<JournalEntry>>(
        stream: firestoreService.getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No entries yet. Add your first one!'));
          }

          final entries = snapshot.data!;

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: Text(_getEmojiForMood(entry.mood), style: const TextStyle(fontSize: 24)),
                title: Text(entry.text, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateFormat.yMMMd().format(entry.date)), // Format the date nicely
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper function to get an emoji for a mood
  String _getEmojiForMood(String mood) {
    switch (mood) {
      case 'happy': return '😄';
      case 'calm': return '😌';
      case 'neutral': return '😐';
      case 'sad': return '😢';
      case 'angry': return '😠';
      default: return '🤔';
    }
  }
}