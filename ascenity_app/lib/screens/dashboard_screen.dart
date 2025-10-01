import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascenity_app/screens/mood_tracking_page.dart';
import 'package:ascenity_app/screens/journaling_page.dart';
import 'package:ascenity_app/screens/streaks_screen.dart';
import 'package:ascenity_app/services/firestore_services.dart';
import 'package:ascenity_app/design/tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ascenity_app/screens/settings_page.dart';
import 'package:ascenity_app/screens/meditate_screen.dart';
import 'package:ascenity_app/navigation/animated_routes.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final PageController _moodController = PageController(viewportFraction: 0.55, initialPage: 1);
  final FirestoreService _firestoreService = FirestoreService();
  late AnimationController _animationController;

  final List<_MoodCardConfig> _moods = const [
    _MoodCardConfig(
      label: 'Sad',
      emoji: '😔',
      gradient: [AscenityColors.oxfordBlue, AscenityColors.honoluluBlue],
      color: AscenityColors.honoluluBlue,
    ),
    _MoodCardConfig(
      label: 'Calm',
      emoji: '😐',
      gradient: [AscenityColors.robinEggBlue, AscenityColors.honoluluBlue],
      color: AscenityColors.robinEggBlue,
    ),
    _MoodCardConfig(
      label: 'Happy',
      emoji: '😄',
      gradient: [AscenityColors.emerald, AscenityColors.robinEggBlue],
      color: AscenityColors.emerald,
    ),
  ];

  int _currentMoodIndex = 1;
  DashboardSnapshot? _snapshot;
  bool _loading = true;
  Color? _overlayColor;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
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
    _animationController.dispose();
    super.dispose();
  }

  void _onMoodSelected(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMoodIndex = index;
      _overlayColor = _moods[index].color.withOpacity(0.1);
    });
    
    // Fade out the overlay color after a delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _overlayColor = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final greeting = _greeting();
    final name = (user?.displayName?.split(' ').first ?? 'Friend');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Theme.of(context).colorScheme.background : Theme.of(context).scaffoldBackgroundColor,
              if (_overlayColor != null)
                _overlayColor!
              else
                isDark ? Theme.of(context).colorScheme.background : Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Collapsing app bar with greeting
            SliverAppBar(
              expandedHeight: 160.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final top = constraints.biggest.height;
                  final expandRatio = (top - kToolbarHeight) / (160 - kToolbarHeight);
                  final adjustedRatio = expandRatio.clamp(0.0, 1.0);
                  
                  return FlexibleSpaceBar(
                    title: Opacity(
                      opacity: 1.0 - adjustedRatio,
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    background: _GreetingHeader(
                      greeting: greeting,
                      name: name,
                      avatar: user?.photoURL,
                    ),
                  );
                },
              ),
            ),
          
            // Mood selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
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
                  ],
                ),
              ),
            ),
            
            // Progress rings section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProgressRingsSection(
                      snapshot: _snapshot, 
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
            
            // Quick actions grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _QuickActionsGrid(),
                  ],
                ),
              ),
            ),
          ],
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

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final String? avatar;

  const _GreetingHeader({
    required this.greeting,
    required this.name,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                SharedAxisPageRoute(
                  page: const SettingsPage(),
                  transitionType: SharedAxisTransitionType.vertical,
                ),
              );
            },
            child: Hero(
              tag: 'user-avatar',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                backgroundImage: avatar != null ? NetworkImage(avatar!) : null,
                child: avatar == null ? const Icon(Icons.person) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
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

class _MoodCardState extends State<_MoodCard> with SingleTickerProviderStateMixin {
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
      begin: widget.selected ? 1.0 : 0.85,
      end: widget.selected ? 1.0 : 0.85,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void didUpdateWidget(_MoodCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _scaleAnimation = Tween<double>(
        begin: _scaleAnimation.value,
        end: widget.selected ? 1.0 : 0.85,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      _controller.forward(from: 0.0);
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
                    style: const TextStyle(fontSize: 64)
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

class _ProgressRingsSection extends StatelessWidget {
  final DashboardSnapshot? snapshot;
  final bool loading;
  
  const _ProgressRingsSection({
    required this.snapshot,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    
    final data = snapshot ?? DashboardSnapshot.empty();
    
    return AnimationLimiter(
      child: Row(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 600),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: [
            Expanded(
              child: _ProgressRingCard(
                label: 'Daily Check-in',
                progress: data.moodLoggedToday ? 1.0 : 0.0,
                subtitle: data.moodLoggedToday ? 'Mood logged' : 'Tap to log',
                color: Theme.of(context).colorScheme.secondary, // Robin Egg Blue
                icon: Icons.mood,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ProgressRingCard(
                label: 'Journal Entry',
                progress: data.journalLoggedToday ? 1.0 : 0.0,
                subtitle: data.journalLoggedToday ? 'Completed' : 'Write today',
                color: Theme.of(context).colorScheme.tertiary, // Emerald
                icon: Icons.edit_note,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRingCard extends StatelessWidget {
  final String label;
  final double progress;
  final String subtitle;
  final Color color;
  final IconData icon;
  
  const _ProgressRingCard({
    required this.label,
    required this.progress,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF121259)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                    Center(
                      child: Icon(
                        icon,
                        size: 32,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle, 
            textAlign: TextAlign.center, 
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final actions = [
      _QuickActionInfo(
        icon: Icons.mood,
        label: 'Log Mood',
        color: scheme.secondary,
        route: const MoodTrackingPage(),
      ),
      _QuickActionInfo(
        icon: Icons.edit_note,
        label: 'Journal',
        color: scheme.primary,
        route: const JournalingPage(),
      ),
      _QuickActionInfo(
        icon: Icons.local_fire_department,
        label: 'Streaks',
        color: scheme.tertiary,
        route: const StreaksScreen(),
      ),
      _QuickActionInfo(
        icon: Icons.spa,
        label: 'Meditate',
        color: scheme.secondary,
        route: const MeditateScreen(),
      ),
    ];

    return AnimationLimiter(
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.4,
        children: List.generate(
          actions.length,
          (index) => AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _QuickActionCard(
                  action: actions[index],
                  delay: index * 100,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  final _QuickActionInfo action;
  final int delay;
  
  const _QuickActionCard({
    required this.action,
    required this.delay,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Delayed start
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(_controller),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
          HapticFeedback.lightImpact();
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          final target = widget.action.route;
          if (target is MoodTrackingPage) {
            Navigator.of(context).push(
              SharedAxisPageRoute(
                page: target,
                transitionType: SharedAxisTransitionType.horizontal,
              ),
            );
          } else if (target is JournalingPage) {
            Navigator.of(context).push(
              SharedAxisPageRoute(
                page: target,
                transitionType: SharedAxisTransitionType.scaled,
              ),
            );
          } else if (target is StreaksScreen) {
            Navigator.of(context).push(
              SharedAxisPageRoute(
                page: target,
                transitionType: SharedAxisTransitionType.vertical,
              ),
            );
          } else {
            Navigator.of(context).push(
              SharedAxisPageRoute(
                page: target,
                transitionType: SharedAxisTransitionType.scaled,
              ),
            );
          }
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: _isPressed 
              ? (Matrix4.identity()..scale(0.95))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF121259)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: _isPressed 
                ? [] 
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.action.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.action.icon,
                  color: widget.action.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.action.label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionInfo {
  final IconData icon;
  final String label;
  final Color color;
  final Widget route;
  
  const _QuickActionInfo({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _MoodCardConfig {
  final String label;
  final String emoji;
  final List<Color> gradient;
  final Color color;
  
  const _MoodCardConfig({
    required this.label,
    required this.emoji,
    required this.gradient,
    required this.color,
  });
}

class DashboardSnapshot {
  final bool moodLoggedToday;
  final bool journalLoggedToday;
  final int longestStreak;

  const DashboardSnapshot({
    required this.moodLoggedToday,
    required this.journalLoggedToday,
    required this.longestStreak,
  });

  factory DashboardSnapshot.empty() => const DashboardSnapshot(
    moodLoggedToday: false,
    journalLoggedToday: false,
    longestStreak: 0,
  );
}