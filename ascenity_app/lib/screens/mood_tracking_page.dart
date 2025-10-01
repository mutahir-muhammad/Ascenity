import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/mood_streak_provider.dart';
import '../providers/theme_provider.dart';
import '../models/mood_entry.dart';

class MoodTrackingPage extends StatefulWidget {
  const MoodTrackingPage({super.key});

  @override
  State<MoodTrackingPage> createState() => _MoodTrackingPageState();
}

class _MoodTrackingPageState extends State<MoodTrackingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _moodController = PageController(viewportFraction: 0.8);
  int _currentMoodIndex = 0;

  final List<_MoodCardConfig> _moods = const [
    _MoodCardConfig(
      label: 'Sad',
      emoji: '😔',
      gradient: [Color(0xFF2C2C54), Color(0xFF6C5CE7)],
      color: Color(0xFF6C5CE7),
      score: 1,
    ),
    _MoodCardConfig(
      label: 'Calm',
      emoji: '😌',
      gradient: [Color(0xFF40D5FF), Color(0xFF497EFF)],
      color: Color(0xFF40D5FF),
      score: 3,
    ),
    _MoodCardConfig(
      label: 'Happy',
      emoji: '😄',
      gradient: [Color(0xFF57FFBB), Color(0xFF40D5FF)],
      color: Color(0xFF57FFBB),
      score: 5,
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
    _moodController.dispose();
    super.dispose();
  }

  void _onMoodSelected(int index) {
    setState(() {
      _currentMoodIndex = index;
    });
    
    final themeProvider = context.read<ThemeProvider>();
    themeProvider.updateThemeForMood(_moods[index].label);
  }

  Future<void> _saveMood() async {
    final moodConfig = _moods[_currentMoodIndex];
    final provider = context.read<MoodStreakProvider>();

    try {
      await provider.recordMood(
        moodScore: moodConfig.score,
        moodLabel: moodConfig.label,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood recorded: ${moodConfig.label}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to record mood. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mood Tracker',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Record Mood'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecordMoodTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _saveMood,
              icon: const Icon(Icons.check),
              label: const Text('Save Mood'),
            )
          : null,
    );
  }

  Widget _buildRecordMoodTab() {
    return Consumer<MoodStreakProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnimationLimiter(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: widget,
                ),
              ),
              children: [
                Text(
                  'How are you feeling today?',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _moodController,
                    itemCount: _moods.length,
                    onPageChanged: _onMoodSelected,
                    itemBuilder: (context, index) {
                      final config = _moods[index];
                      final selected = index == _currentMoodIndex;
                      return _MoodCard(
                        config: config,
                        selected: selected,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                if (provider.todaysMood != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Mood',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You recorded feeling ${provider.todaysMood!.moodLabel} '
                            'at ${DateFormat.jm().format(provider.todaysMood!.timestamp)}',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<MoodStreakProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildMoodChart(provider.recentMoods),
            const SizedBox(height: 24),
            Text(
              'Recent Moods',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildMoodList(provider.recentMoods),
          ],
        );
      },
    );
  }

  Widget _buildMoodChart(List<MoodEntry> moods) {
    if (moods.isEmpty) {
      return const SizedBox.shrink();
    }

    final moodData = <FlSpot>[];
    final dates = <DateTime>[];
    for (var i = 0; i < moods.length; i++) {
      moodData.add(FlSpot(i.toDouble(), moods[i].moodScore.toDouble()));
      dates.add(moods[i].timestamp);
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 7 != 0) return const SizedBox.shrink();
                  final index = value.toInt();
                  if (index >= dates.length) return const SizedBox.shrink();
                  return Text(
                    DateFormat.MMMd().format(dates[index]),
                    style: GoogleFonts.poppins(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: moodData,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodList(List<MoodEntry> moods) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moods.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final mood = moods[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getMoodColor(mood.moodLabel).withOpacity(0.2),
            child: Text(
              _getMoodEmoji(mood.moodLabel),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          title: Text(
            mood.moodLabel,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat.yMMMd().add_jm().format(mood.timestamp),
            style: GoogleFonts.poppins(),
          ),
          trailing: Text(
            'Score: ${mood.moodScore}',
            style: GoogleFonts.poppins(),
          ),
        );
      },
    );
  }

  Color _getMoodColor(String moodLabel) {
    return _moods
        .firstWhere(
          (mood) => mood.label.toLowerCase() == moodLabel.toLowerCase(),
          orElse: () => _moods[1], // Default to calm
        )
        .color;
  }

  String _getMoodEmoji(String moodLabel) {
    return _moods
        .firstWhere(
          (mood) => mood.label.toLowerCase() == moodLabel.toLowerCase(),
          orElse: () => _moods[1], // Default to calm
        )
        .emoji;
  }
}

class _MoodCardConfig {
  final String label;
  final String emoji;
  final List<Color> gradient;
  final Color color;
  final int score;

  const _MoodCardConfig({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.color,
    required this.score,
  });
}

class _MoodCard extends StatefulWidget {
  final _MoodCardConfig config;
  final bool selected;

  const _MoodCard({
    required this.config,
    required this.selected,
  });

  @override
  State<_MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<_MoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant _MoodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                if (widget.selected)
                  BoxShadow(
                    color: widget.config.color.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.config.gradient,
              ),
              border: Border.all(
                color: widget.selected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.config.emoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.config.label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
