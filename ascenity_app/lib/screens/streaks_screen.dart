import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:ascenity_app/services/streak_service.dart';
import 'package:shimmer/shimmer.dart';

class StreaksScreen extends StatefulWidget {
  const StreaksScreen({super.key});
  @override
  State<StreaksScreen> createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> {
  final _streakService = StreakService();
  late Future<_ProgressSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ProgressSnapshot> _load() async {
    final stats = await _streakService.getStreakStatistics();
    final userStreak = await _streakService.getUserStreak();
    
    // Calculate mood trends for last 14 days
    final activityDates = userStreak.activityDates;
    final now = DateTime.now();
    List<int> trend14 = List.generate(14, (index) {
      final date = now.subtract(Duration(days: 13 - index));
      final dateStr = date.toIso8601String().split('T')[0];
      return activityDates.contains(dateStr) ? 1 : 0;
    });

    // Calculate weekly reflections
    List<int> weeklyCount = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = date.toIso8601String().split('T')[0];
      return activityDates.contains(dateStr) ? 1 : 0;
    });

    return _ProgressSnapshot(
      trends: _Trends(trend14: trend14, week: weeklyCount),
      streak: stats['currentStreak'] as int,
      longest: stats['longestStreak'] as int,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress & Streaks', 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<_ProgressSnapshot>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data!;
          final badges = _badges;
          final celebrate = data.streak >= 7 && data.streak % 7 == 0;

          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _StreakHeader(currentStreak: data.streak, longestStreak: data.longest, celebrate: celebrate),
                  const SizedBox(height: 20),
                  const Text('Mood trend • last 14 days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _MoodTrendChart(trends: data.trends.trend14),
                  const SizedBox(height: 24),
                  const Text('Weekly reflections', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _ReflectionChart(weeklyCounts: data.trends.week),
                  const SizedBox(height: 24),
                  const Text('Achievement badges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: badges
                        .map((badge) => _BadgeChip(
                              badge: badge,
                              unlocked: data.streak >= badge.threshold,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              if (celebrate)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Lottie.asset('assets/animations/confetti.json', repeat: false),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<_Badge> get _badges => const [
        _Badge(
          title: 'First Flame',
          description: 'Log your mood 3 days in a row.',
          threshold: 3,
          icon: Icons.local_fire_department,
          bonusInfo: 'Start building a healthy daily check-in habit.',
        ),
        _Badge(
          title: 'Consistency Star',
          description: 'Keep a 7 day journaling streak.',
          threshold: 7,
          icon: Icons.star_rate,
          bonusInfo: 'Maintain mindfulness for a full week. You\'re doing great!',
        ),
        _Badge(
          title: 'Mindful Master',
          description: 'Stay consistent for 21 days.',
          threshold: 21,
          icon: Icons.bolt,
          bonusInfo: 'Form a lasting habit of self-reflection and emotional awareness.',
        ),
        _Badge(
          title: 'Resilience Champion',
          description: 'Complete a 30-day streak.',
          threshold: 30,
          icon: Icons.psychology,
          bonusInfo: 'You\'ve made emotional well-being a priority in your life.',
        ),
      ];
}

class _Trends {
  final List<int> trend14;
  final List<int> week;
  const _Trends({required this.trend14, required this.week});
}

class _ProgressSnapshot {
  final _Trends trends;
  final int streak;
  final int longest;
  const _ProgressSnapshot({required this.trends, required this.streak, required this.longest});
}

class _StreakHeader extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final bool celebrate;
  const _StreakHeader({required this.currentStreak, required this.longestStreak, required this.celebrate});

  @override
  State<_StreakHeader> createState() => _StreakHeaderState();
}

class _StreakHeaderState extends State<_StreakHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.currentStreak > 0 ? 1.15 : 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    final card = Card(
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Row(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.currentStreak > 0) 
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        Lottie.asset(
                          'assets/animations/flame.json',
                          repeat: true,
                          width: widget.currentStreak > 7 ? 80 : 70,
                          height: widget.currentStreak > 7 ? 80 : 70,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current streak',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (widget.currentStreak > 5)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${widget.currentStreak}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'days',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: widget.longestStreak > 0 ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Best: ${widget.longestStreak} days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.trending_up_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(widget.longestStreak > 0 ? (widget.currentStreak / widget.longestStreak * 100) : 0).toStringAsFixed(0)}% of best',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (widget.celebrate)
                  const Icon(Icons.celebration, color: Colors.orangeAccent, size: 32)
                else if (widget.currentStreak > 0)
                  Icon(
                    Icons.trending_up,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  )
                else
                  Icon(
                    Icons.timelapse,
                    size: 28,
                    color: Colors.grey,
                  ),
                if (widget.currentStreak > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStreakStatus(widget.currentStreak),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    // Subtle shimmer overlay to add a premium feel
    return Stack(
      children: [
        card,
        Positioned.fill(
          child: IgnorePointer(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.transparent,
                  highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                  period: const Duration(seconds: 3),
                  child: Transform.rotate(
                    angle: 0.2,
                    child: Container(
                      width: 120,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _getStreakStatus(int streak) {
    if (streak >= 30) return 'Epic!';
    if (streak >= 21) return 'Superb!';
    if (streak >= 14) return 'Amazing!';
    if (streak >= 7) return 'Great!';
    if (streak >= 3) return 'Good!';
    return 'Started!';
  }
}

class _MoodTrendChart extends StatefulWidget {
  final List<int> trends;
  const _MoodTrendChart({required this.trends});

  @override
  State<_MoodTrendChart> createState() => _MoodTrendChartState();
}

class _MoodTrendChartState extends State<_MoodTrendChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary; // Honolulu Blue
  final secondary = Theme.of(context).colorScheme.secondary; // Robin Egg Blue
  final tertiary = Theme.of(context).colorScheme.tertiary; // Emerald
    
    final maxY = (widget.trends.isEmpty ? 5.0 : widget.trends.reduce((a, b) => a > b ? a : b).toDouble() + 2);
    
    final spots = [
      for (int i = 0; i < widget.trends.length; i++) FlSpot(i.toDouble(), widget.trends[i].toDouble()),
    ];
    
    return SizedBox(
      height: 180,
      child: Card(
        elevation: 2,
        shadowColor: primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 16.0, 16.0, 12.0),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              return LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          // Only show dates for 0, 4, 8, and 12
                          if (index % 4 == 0 && index < widget.trends.length) {
                            final dayText = _getDayText(index);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dayText,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 25,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value % 2 != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 4,
                      gradient: LinearGradient(colors: [primary, secondary]),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                        checkToShowDot: (spot, barData) {
                          return spot.x % 2 == 0; // Only show dots every other point
                        },
                      ),
                      spots: spots,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            primary.withValues(alpha: 0.25),
                            tertiary.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (spots) => Theme.of(context).cardColor,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final dayIndex = touchedSpot.x.toInt();
                          final dayText = _getDayText(dayIndex);
                          return LineTooltipItem(
                            '${touchedSpot.y.toInt()} entries\n$dayText',
                            TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 800),
              );
            },
          ),
        ),
      ),
    );
  }
  
  String _getDayText(int dayIndex) {
    final today = DateTime.now();
    final day = today.subtract(Duration(days: 13 - dayIndex));
    return '${day.month}/${day.day}';
  }
}

class _ReflectionChart extends StatefulWidget {
  final List<int> weeklyCounts;
  const _ReflectionChart({required this.weeklyCounts});
  
  @override
  State<_ReflectionChart> createState() => _ReflectionChartState();
}

class _ReflectionChartState extends State<_ReflectionChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    
    Future.microtask(() => _animationController.forward());
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    
    final maxBarHeight = widget.weeklyCounts.isEmpty 
        ? 5.0 
        : (widget.weeklyCounts.reduce((a, b) => a > b ? a : b).toDouble() + 1).clamp(3.0, 10.0);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final bars = [
          for (int i = 0; i < widget.weeklyCounts.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: widget.weeklyCounts[i].toDouble() * _animation.value,
                  width: 22,
                  gradient: LinearGradient(
                    colors: [
                      primary, 
                      secondary,
                      i == DateTime.now().weekday - 1 ? tertiary : secondary,  // Highlight today
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxBarHeight.toDouble(),
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  rodStackItems: widget.weeklyCounts[i] > 0 ? [
                    BarChartRodStackItem(
                      0, 
                      widget.weeklyCounts[i].toDouble() * _animation.value, 
                      primary.withValues(alpha: 0.7), 
                      BorderSide.none
                    ),
                  ] : [],
                ),
              ],
              showingTooltipIndicators: i == DateTime.now().weekday - 1 ? [0] : [], // Show tooltip for today
            ),
        ];
        
        return SizedBox(
          height: 220,
          child: Card(
            elevation: 2,
            shadowColor: primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 12.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      if (value == 0) return FlLine(color: Colors.transparent);
                      return FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final daysOfWeek = _getDaysOfWeek();
                          final today = DateTime.now().weekday - 1; // 0-indexed
                          
                          if (index >= 0 && index < daysOfWeek.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                children: [
                                  Text(
                                    daysOfWeek[index],
                                    style: TextStyle(
                                      color: index == today 
                                          ? primary 
                                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: index == today ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                  if (index == today)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: primary,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          if (value % 1 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: bars,
                  maxY: maxBarHeight,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Theme.of(context).cardColor,
                      tooltipRoundedRadius: 12,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final daysOfWeek = _getDaysOfWeek();
                        final value = rod.toY ~/ _animation.value;
                        return BarTooltipItem(
                          '$value ${value == 1 ? 'entry' : 'entries'}\n${daysOfWeek[groupIndex]}',
                          TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        );
      },
    );
  }
  
  List<String> _getDaysOfWeek() {
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }
}

class _Badge {
  final String title;
  final String description;
  final String bonusInfo;
  final int threshold;
  final IconData icon;
  const _Badge({
    required this.title,
    required this.description,
    required this.threshold,
    required this.icon,
    required this.bonusInfo,
  });
}

class _BadgeChip extends StatefulWidget {
  final _Badge badge;
  final bool unlocked;
  const _BadgeChip({required this.badge, required this.unlocked});

  @override
  State<_BadgeChip> createState() => _BadgeChipState();
}

class _BadgeChipState extends State<_BadgeChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
    ));
    
    if (widget.unlocked) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _controller.forward();
      });
    }
  }
  
  @override
  void didUpdateWidget(_BadgeChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlocked && !oldWidget.unlocked) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final color = widget.unlocked 
    ? Theme.of(context).colorScheme.primary 
    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: widget.unlocked ? 1 : 0.5,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.unlocked ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.unlocked ? _rotateAnimation.value : 0,
              child: child,
            ),
          );
        },
        child: Tooltip(
          message: widget.badge.bonusInfo,
          waitDuration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          preferBelow: false,
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.4)),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: widget.unlocked ? 0.05 : 0.02),
              boxShadow: widget.unlocked ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ] : null,
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: Icon(
                      widget.badge.icon,
                      key: ValueKey<bool>(widget.unlocked),
                      color: widget.unlocked 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                    child: widget.unlocked
                        ? Padding(
                            key: const ValueKey('check'),
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: color,
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('no-check')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.badge.title, 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color, 
                  fontWeight: FontWeight.w700
                )
              ),
              const SizedBox(height: 6),
              Text(
                widget.badge.description, 
                style: Theme.of(context).textTheme.bodySmall
              ),
              const SizedBox(height: 6),
              Text(
                widget.unlocked 
                    ? 'Achievement unlocked!' 
                    : 'Requires ${widget.badge.threshold} day streak', 
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color.withValues(alpha: 0.8)
                )
              ),
            ],
          )),
        ),
      ),
    );
  }
}