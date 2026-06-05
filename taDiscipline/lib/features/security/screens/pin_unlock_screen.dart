import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/features/security/services/pin_service.dart';
import 'package:ta_discipline/features/security/services/biometric_service.dart';
import 'package:ta_discipline/data/repositories/auth_repository.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  final VoidCallback onUnlock;

  const PinUnlockScreen({super.key, required this.onUnlock});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  final _pinController = TextEditingController();
  late PinService _pinService;
  late BiometricService _biometricService;
  bool _biometricAttempted = false;

  @override
  void initState() {
    super.initState();
    _pinService = PinService(AuthRepository());
    _biometricService = BiometricService(AuthRepository());
    _tryBiometric();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    if (_biometricAttempted) return;
    _biometricAttempted = true;
    final available = await _biometricService.isBiometricAvailable;
    if (available && mounted) {
      final authenticated = await _biometricService.authenticate();
      if (authenticated && mounted) {
        widget.onUnlock();
      }
    }
  }

  void _onDigit(String digit) {
    if (_pinController.text.length >= 6) return;
    _pinController.text += digit;
    if (_pinController.text.length == 6) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_pinController.text.isNotEmpty) {
      _pinController.text = _pinController.text
          .substring(0, _pinController.text.length - 1);
    }
  }

  Future<void> _verifyPin() async {
    final valid = await _pinService.verifyPin(_pinController.text);
    if (valid) {
      widget.onUnlock();
    } else {
      setState(() => _pinController.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Code incorrect. ${_pinService.failedAttempts} tentative(s) échouée(s).',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'D',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'taDiscipline',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Code PIN',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pinController.text.length;
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppColors.primary : AppColors.surface,
                      border: Border.all(
                        color: filled
                            ? AppColors.primary
                            : AppColors.glassBorder,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    ...List.generate(9, (i) => _NumpadKey(
                      label: '${i + 1}',
                      onTap: () => _onDigit('${i + 1}'),
                    )),
                    const SizedBox.shrink(),
                    _NumpadKey(
                      label: '0',
                      onTap: () => _onDigit('0'),
                    ),
                    _NumpadKey(
                      label: '⌫',
                      onTap: _onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
