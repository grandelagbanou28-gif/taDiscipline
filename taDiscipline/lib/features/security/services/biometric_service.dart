import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ta_discipline/data/repositories/auth_repository.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final AuthRepository _authRepository;

  BiometricService(this._authRepository);

  Future<bool> get isBiometricAvailable async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Erreur vérification biométrie: $e');
      return false;
    }
  }

  Future<List<BiometricType>> get availableBiometrics async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Erreur biométries disponibles: $e');
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Déverrouiller taDiscipline',
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      debugPrint('Erreur authentification biométrique: $e');
      return false;
    }
  }

  Future<void> enableBiometric(String userId) async {
    await _authRepository.updateBiometricEnabled(
      userId: userId,
      enabled: true,
    );
  }

  Future<void> disableBiometric(String userId) async {
    await _authRepository.updateBiometricEnabled(
      userId: userId,
      enabled: false,
    );
  }
}
