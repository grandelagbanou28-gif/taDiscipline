import 'dart:async';
import 'package:flutter/foundation.dart';

class AutoLockService {
  Timer? _timer;
  Timer? _activityTimer;
  int _timeoutSeconds = 120;
  bool _isLocked = false;

  final void Function() onAutoLock;

  AutoLockService({required this.onAutoLock});

  bool get isLocked => _isLocked;

  void setLockTimeout(int minutes) {
    _timeoutSeconds = minutes * 60;
  }

  void start() {
    _resetTimer();
  }

  void resetTimer() {
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: _timeoutSeconds), _lock);
  }

  void _lock() {
    _isLocked = true;
    onAutoLock();
  }

  void unlock() {
    _isLocked = false;
    _resetTimer();
  }

  void dispose() {
    _timer?.cancel();
    _activityTimer?.cancel();
  }
}
