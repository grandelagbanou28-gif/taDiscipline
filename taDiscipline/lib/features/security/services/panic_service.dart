import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanicService {
  bool _isActive = false;
  VoidCallback? _onToggle;

  bool get isActive => _isActive;

  void initialize(VoidCallback onToggle) {
    _onToggle = onToggle;
  }

  void activate() {
    _isActive = true;
    HapticFeedback.heavyImpact();
    _onToggle?.call();
  }

  void deactivate() {
    _isActive = false;
    _onToggle?.call();
  }

  void toggle() {
    if (_isActive) {
      deactivate();
    } else {
      activate();
    }
  }
}
