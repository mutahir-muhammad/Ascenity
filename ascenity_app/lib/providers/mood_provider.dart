import 'package:flutter/foundation.dart';

class MoodProvider extends ChangeNotifier {
  // 0 = sad, 1 = neutral, 2 = happy
  int _level = 1;
  bool _justSaved = false;

  int get level => _level;
  bool get justSaved => _justSaved;

  void setLevel(int v) {
    if (v == _level) return;
    _level = v.clamp(0, 2);
    notifyListeners();
  }

  String get moodLabel => switch (_level) { 0 => 'sad', 1 => 'neutral', _ => 'happy' };
  String get moodEmoji => switch (_level) { 0 => '😔', 1 => '😐', _ => '😄' };

  void setJustSaved(bool v) {
    _justSaved = v;
    notifyListeners();
  }
}
