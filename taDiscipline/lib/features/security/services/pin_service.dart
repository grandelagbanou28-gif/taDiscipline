import 'package:flutter/services.dart';
import 'package:apex/core/utils/encryption.dart';
import 'package:apex/data/repositories/auth_repository.dart';

class PinService {
  final AuthRepository _authRepository;
  String? _currentPinHash;
  String? _currentSalt;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  PinService(this._authRepository);

  bool get isLocked =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  Duration get lockoutRemaining {
    if (_lockoutUntil == null) return Duration.zero;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  int get failedAttempts => _failedAttempts;

  bool get hasPin => _currentPinHash != null && _currentSalt != null;

  Future<void> initialize(String userId) async {
    final profile = await _authRepository.getProfile(userId);
    _currentPinHash = profile.pinHash;
    _currentSalt = profile.pinSalt;
  }

  Future<bool> setPin(String userId, String pin) async {
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      return false;
    }
    final salt = EncryptionService.generateSalt();
    final hash = EncryptionService.hashPassword(pin, salt);
    await _authRepository.updatePinHash(
      userId: userId,
      pinHash: hash,
      salt: salt,
    );
    _currentPinHash = hash;
    _currentSalt = salt;
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    if (isLocked) return false;
    if (_currentPinHash == null || _currentSalt == null) return false;
    final hash = EncryptionService.hashPassword(pin, _currentSalt!);
    if (hash == _currentPinHash) {
      _failedAttempts = 0;
      return true;
    }
    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockoutUntil = DateTime.now().add(const Duration(minutes: 15));
    }
    return false;
  }

  void resetAttempts() {
    _failedAttempts = 0;
    _lockoutUntil = null;
  }

  Future<void> removePin(String userId) async {
    await _authRepository.updatePinHash(
      userId: userId,
      pinHash: '',
      salt: '',
    );
    _currentPinHash = null;
    _currentSalt = null;
  }
}
