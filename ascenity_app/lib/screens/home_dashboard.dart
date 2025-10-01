import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ascenity_app/screens/mood_tracking_page.dart';
import 'package:ascenity_app/screens/journaling_page.dart';
import 'package:ascenity_app/screens/streaks_screen.dart';
import 'package:ascenity_app/services/firestore_services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController _moodController = PageController(viewportFraction: 0.55, initialPage: 1);
  final FirestoreService _firestoreService = FirestoreService();

  final List<_MoodCardConfig> _moods = const [
    _MoodCardConfig(label: 'Sad', emoji: '😔', gradient: [Color(0xFF2C2C54), Color(0xFF6C5CE7)]),
    _MoodCardConfig(label: 'Calm', emoji: '😐', gradient: [Color(0xFF40D5FF), Color(0xFF497EFF)]),
    _MoodCardConfig(label: 'Happy', emoji: '😄', gradient: [Color(0xFF57FFBB), Color(0xFF40D5FF)]),
  ];

  int _currentMoodIndex = 1;
  DashboardSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await _firestoreService.dashboardSnapshot();
    if (!mounted) return;
    setState(() {
      _snapshot = DashboardSnapshot(
        moodLoggedToday: snapshot.moodLoggedToday,
        journalLoggedToday: snapshot.journalLoggedToday,
        longestStreak: snapshot.longestStreak,
      );
      _loading = false;
    });
  }

  @override
  void dispose() {
    _moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _moods[_currentMoodIndex].gradient;
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _greeting();
    final name = (user?.displayName?.split(' ').first ?? 'Friend');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('$greeting, $name 🌞'),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadSnapshot,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text(
                  'Tap the mood that matches your vibe today.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _moodController,
                    itemCount: _moods.length,
                    onPageChanged: (index) => setState(() => _currentMoodIndex = index),
                    itemBuilder: (context, index) {
                      final config = _moods[index];
                      final selected = index == _currentMoodIndex;
                      return AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: selected ? 1.0 : 0.85,
                        child: _MoodCard(config: config, selected: selected),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _SnapshotSection(snapshot: _snapshot, loading: _loading),
                const SizedBox(height: 24),
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.mood_outlined,
                        label: 'Log Mood',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoodTrackingPage())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.edit_note,
                        label: 'Journal Now',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JournalingPage())),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.auto_graph,
                        label: 'See Progress',
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StreaksScreen())),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

class _MoodCard extends StatelessWidget {
  final _MoodCardConfig config;
  final bool selected;
  const _MoodCard({required this.config, required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (selected) BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: config.gradient,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(config.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(config.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodCardConfig {
  final String label;
  final String emoji;
  final List<Color> gradient;
  const _MoodCardConfig({required this.label, required this.emoji, required this.gradient});
}

class _SnapshotSection extends StatelessWidget {
  final DashboardSnapshot? snapshot;
  final bool loading;
  const _SnapshotSection({required this.snapshot, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final data = snapshot ?? DashboardSnapshot.empty();
    return Row(
      children: [
        Expanded(
          child: _ProgressRing(
            label: 'Daily Check-in',
            progress: data.moodLoggedToday ? 1.0 : 0.0,
            subtitle: data.moodLoggedToday ? 'Mood logged' : 'Tap Log Mood',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProgressRing(
            label: 'Journal Entry',
            progress: data.journalLoggedToday ? 1.0 : 0.0,
            subtitle: data.journalLoggedToday ? 'Journaled today' : 'Write your thoughts',
          ),
        ),
      ],
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final String label;
  final double progress;
  final String subtitle;
  const _ProgressRing({required this.label, required this.progress, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return SizedBox(
                height: 92,
                width: 92,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value == 0 ? null : value,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                    ),
                    Center(
                      child: Text(
                        value == 0 ? '0%' : '${(value * 100).round()}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

class DashboardSnapshot {
  final bool moodLoggedToday;
  final bool journalLoggedToday;
  final int longestStreak;

  const DashboardSnapshot({required this.moodLoggedToday, required this.journalLoggedToday, required this.longestStreak});

  factory DashboardSnapshot.empty() => const DashboardSnapshot(moodLoggedToday: false, journalLoggedToday: false, longestStreak: 0);
}
