import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascenity_app/services/firestore_services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:ascenity_app/navigation/animated_routes.dart';
import 'package:animations/animations.dart';
import 'package:ascenity_app/screens/ai_insights_sheet.dart';

class JournalingPage extends StatefulWidget {
  const JournalingPage({super.key});
  @override
  State<JournalingPage> createState() => _JournalingPageState();
}

class _JournalingPageState extends State<JournalingPage> with SingleTickerProviderStateMixin {
  final _firestore = FirestoreService();
  late TabController _tabController;
  // SentimentResult? _lastResult; // Reserved for future AI insights

  // Sample entries for demonstration
  final List<_JournalEntry> _entries = [
    _JournalEntry(
      id: '1',
      title: 'Finding Peace in Chaos',
      content: 'Today was overwhelming but I managed to find moments of calm by focusing on my breathing...',
      date: DateTime.now().subtract(const Duration(days: 1)),
      mood: 'Reflective',
      color: Colors.lightBlueAccent,
    ),
    _JournalEntry(
      id: '2',
      title: 'Small Victories',
      content: 'I completed that project I\'ve been putting off for weeks. It wasn\'t as hard as I thought...',
      date: DateTime.now().subtract(const Duration(days: 3)),
      mood: 'Accomplished',
      color: Colors.tealAccent,
    ),
    _JournalEntry(
      id: '3',
      title: 'Gratitude Practice',
      content: 'Three things I\'m grateful for today: 1. My morning coffee 2. The supportive text from a friend 3. The sunset view from my window',
      date: DateTime.now().subtract(const Duration(days: 5)),
      mood: 'Grateful',
      color: Colors.blueAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Journal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Entries'),
            Tab(text: 'Insights'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search functionality
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _navigateToDetailPage(null);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Entries Tab
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your thoughts matter',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Capture your moments of clarity and reflection',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Journal entries list
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 500),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _JournalEntryCard(
                            entry: _entries[index],
                            onTap: () => _navigateToDetailPage(_entries[index]),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _entries.length,
                ),
              ),
              
              // Empty space at the bottom to account for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
          
          // Insights Tab
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'AI Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap below to view a summary of your recent entries.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.insights),
                  label: const Text('Open AI Insights'),
                  onPressed: () => showAIInsightsBottomSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _navigateToDetailPage(_JournalEntry? entry) {
    Navigator.of(context).push(
      SharedAxisPageRoute(
        transitionType: SharedAxisTransitionType.scaled,
        page: JournalDetailPage(
          existingEntry: entry,
          onSave: (title, content, mood) async {
            // In a real app, we'd save to Firestore here
            await _firestore.addEntry(content, mood, prompt: title);
          },
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatefulWidget {
  final _JournalEntry entry;
  final VoidCallback onTap;
  
  const _JournalEntryCard({
    required this.entry,
    required this.onTap,
  });

  @override
  State<_JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<_JournalEntryCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: GestureDetector(
        onTapDown: (_) {
          _controller.forward();
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () {
          _controller.reverse();
        },
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Hero(
            tag: 'journal-${widget.entry.id}',
            child: Container(
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF121259)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: widget.entry.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and mood indicator
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 12,
                              width: 12,
                              decoration: BoxDecoration(
                                color: widget.entry.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.entry.mood,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: widget.entry.color,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatDate(widget.entry.date),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      widget.entry.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Content preview
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      widget.entry.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}

class JournalDetailPage extends StatefulWidget {
  final _JournalEntry? existingEntry;
  final Function(String title, String content, String mood) onSave;
  
  const JournalDetailPage({
    super.key,
    this.existingEntry,
    required this.onSave,
  });

  @override
  State<JournalDetailPage> createState() => _JournalDetailPageState();
}

class _JournalDetailPageState extends State<JournalDetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isSaving = false;
  bool _savedSuccess = false;
  String _selectedMood = 'Neutral';

  final List<Map<String, dynamic>> _moods = [
    {'name': 'Happy', 'color': Colors.amber},
    {'name': 'Grateful', 'color': Colors.tealAccent},
    {'name': 'Calm', 'color': Colors.lightBlueAccent},
    {'name': 'Reflective', 'color': Colors.indigoAccent},
    {'name': 'Anxious', 'color': Colors.orangeAccent},
    {'name': 'Sad', 'color': Colors.blueGrey},
    {'name': 'Frustrated', 'color': Colors.redAccent},
    {'name': 'Neutral', 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingEntry?.title ?? '');
    _contentController = TextEditingController(text: widget.existingEntry?.content ?? '');
    if (widget.existingEntry != null) {
      _selectedMood = widget.existingEntry!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and content')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      await widget.onSave(
        _titleController.text,
        _contentController.text,
        _selectedMood,
      );
      if (!mounted) return;
      setState(() {
        _savedSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNewEntry = widget.existingEntry == null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewEntry ? 'New Entry' : 'Edit Entry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isSaving
                ? Container(
                    key: const ValueKey('saving'),
                    margin: const EdgeInsets.only(right: 16),
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : _savedSuccess
                    ? Padding(
                        key: const ValueKey('saved'),
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.check_circle, color: Colors.green),
                      )
                    : IconButton(
                        key: const ValueKey('save'),
                        icon: const Icon(Icons.check),
                        onPressed: _saveEntry,
                      ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Optional guided question card
            if (isNewEntry)
              _GuidedQuestionCard(
                onUsePrompt: (prompt) {
                  final text = prompt;
                  final add = _contentController.text.isEmpty ? text : "\n$text";
                  _contentController.text = "${_contentController.text}$add\n";
                  _contentController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _contentController.text.length),
                  );
                },
              ),
            
            // Mood selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    'Mood:',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _moods.map((mood) {
                          final isSelected = mood['name'] == _selectedMood;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMood = mood['name'];
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? mood['color'].withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? mood['color'] : Theme.of(context).dividerColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: mood['color'],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    mood['name'],
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isSelected 
                                          ? mood['color'] 
                                          : Theme.of(context).colorScheme.onSurface,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Title and content fields
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Title field
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Date display
                  Text(
                    _formatDate(widget.existingEntry?.date ?? DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Content field
                  TextField(
                    controller: _contentController,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing here...',
                      hintStyle: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final month = months[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class _GuidedQuestionCard extends StatefulWidget {
  final Function(String) onUsePrompt;
  
  const _GuidedQuestionCard({
    required this.onUsePrompt,
  });
  
  final List<String> _questions = const [
    'What made you feel grateful today?',
    'What was a challenge you faced and how did you handle it?',
    'What is something you learned about yourself today?',
    'What brought you joy in the last 24 hours?',
    'If you could change one thing about today, what would it be?',
  ];

  @override
  State<_GuidedQuestionCard> createState() => _GuidedQuestionCardState();
}

class _GuidedQuestionCardState extends State<_GuidedQuestionCard> {
  int _currentQuestionIndex = 0;
  bool _isVisible = true;

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex = (_currentQuestionIndex + 1) % widget._questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              // Swiped left -> next question
              _nextQuestion();
              HapticFeedback.lightImpact();
            } else if (details.primaryVelocity! > 0) {
              // Swiped right -> dismiss
              setState(() {
                _isVisible = false;
              });
              HapticFeedback.lightImpact();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [
                      Theme.of(context).colorScheme.primary.withOpacity(0.25),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.10),
                    ]
                  : [
                      Theme.of(context).colorScheme.primary.withOpacity(0.10),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Reflection Prompt',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget._questions[_currentQuestionIndex],
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isVisible = false;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.inter(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => widget.onUsePrompt(widget._questions[_currentQuestionIndex]),
                        child: Text(
                          'Use Prompt',
                          style: GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _nextQuestion,
                        child: Row(
                          children: [
                            Text(
                              'Next',
                              style: GoogleFonts.inter(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final Color color;
  
  const _JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.color,
  });
}

// For compatibility with existing code
// These classes would be implemented when AI insights functionality is added
// They've been temporarily removed to avoid lint warnings
