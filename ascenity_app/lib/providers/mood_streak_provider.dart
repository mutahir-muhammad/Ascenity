import 'package:flutter/foundation.dart';
import '../models/mood_entry.dart';
import '../models/user_streak.dart';
import '../services/mood_service.dart';
import '../services/streak_service.dart';

class MoodStreakProvider extends ChangeNotifier {
  final MoodService _moodService;
  final StreakService _streakService;

  MoodEntry? _todaysMood;
  UserStreak? _userStreak;
  List<MoodEntry> _recentMoods = [];
  Map<String, double> _moodAverages = {};
  bool _isLoading = false;

  MoodStreakProvider()
      : _moodService = MoodService(),
        _streakService = StreakService() {
    _initialize();
  }

  MoodEntry? get todaysMood => _todaysMood;
  UserStreak? get userStreak => _userStreak;
  List<MoodEntry> get recentMoods => _recentMoods;
  Map<String, double> get moodAverages => _moodAverages;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await Future.wait([
        _loadTodaysMood(),
        _loadUserStreak(),
        _loadRecentMoods(),
        _loadMoodAverages(),
      ]);
    } catch (e) {
      debugPrint('Error initializing MoodStreakProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _loadTodaysMood() async {
    try {
      _todaysMood = await _moodService.getTodaysMoodEntry();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today\'s mood: $e');
    }
  }

  Future<void> _loadUserStreak() async {
    try {
      _userStreak = await _streakService.getUserStreak();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user streak: $e');
    }
  }

  Future<void> _loadRecentMoods() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      _recentMoods = await _moodService.getMoodEntries(startDate: thirtyDaysAgo);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent moods: $e');
    }
  }

  Future<void> _loadMoodAverages() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      _moodAverages = await _moodService.getMoodAverages(
        startDate: thirtyDaysAgo,
        endDate: DateTime.now(),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood averages: $e');
    }
  }

  Future<void> recordMood({
    required int moodScore,
    required String moodLabel,
    String? note,
  }) async {
    _setLoading(true);
    try {
      await _moodService.saveMoodEntry(
        moodScore: moodScore,
        moodLabel: moodLabel,
        note: note,
      );
      await _streakService.updateUserStreak('mood');
      await Future.wait([
        _loadTodaysMood(),
        _loadUserStreak(),
        _loadRecentMoods(),
        _loadMoodAverages(),
      ]);
      
      // Check for streak milestones
      if (_userStreak != null) {
        final milestones = [7, 14, 21, 30, 60, 90, 180, 365];
        if (milestones.contains(_userStreak!.currentStreak)) {
          await _streakService.recordAchievement('streak_${_userStreak!.currentStreak}');
        }
      }
    } catch (e) {
      debugPrint('Error recording mood: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> getStreakStatistics() async {
    try {
      return await _streakService.getStreakStatistics();
    } catch (e) {
      debugPrint('Error getting streak statistics: $e');
      rethrow;
    }
  }
}