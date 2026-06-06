import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/features/security/services/pin_service.dart';
import 'package:apex/features/security/services/biometric_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: Column(
            children: [
              SizedBox(height: compact ? 40 : 80),
              Container(
                width: compact ? 64 : 80,
                height: compact ? 64 : 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Center(
                  child: Text(
                    'A',
                    style: TextStyle(
                      fontSize: compact ? 32 : 40,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                'Apex',
                style: TextStyle(
                  fontSize: compact ? 24 : 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              SizedBox(height: compact ? 24 : 48),
              const Text(
                'Code PIN',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: compact ? 16 : 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pinController.text.length;
                  return Container(
                    width: compact ? 14 : 16,
                    height: compact ? 14 : 16,
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
              const Spacer(),
              _Numpad(
                compact: compact,
                onDigit: _onDigit,
                onDelete: _onDelete,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final bool compact;
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const _Numpad({
    this.compact = false,
    required this.onDigit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NumpadRow(children: ['1', '2', '3'], compact: compact, onDigit: onDigit),
        SizedBox(height: compact ? 8 : 12),
        _NumpadRow(children: ['4', '5', '6'], compact: compact, onDigit: onDigit),
        SizedBox(height: compact ? 8 : 12),
        _NumpadRow(children: ['7', '8', '9'], compact: compact, onDigit: onDigit),
        SizedBox(height: compact ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: compact ? 64 : 76),
            _NumpadKey(label: '0', compact: compact, onTap: () => onDigit('0')),
            SizedBox(width: compact ? 8 : 12),
            _NumpadKey(label: '⌫', compact: compact, onTap: onDelete),
          ],
        ),
      ],
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> children;
  final bool compact;
  final void Function(String) onDigit;

  const _NumpadRow({
    required this.children,
    this.compact = false,
    required this.onDigit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children.map((label) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
          child: _NumpadKey(label: label, compact: compact, onTap: () => onDigit(label)),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: compact ? 64 : 76,
          height: compact ? 48 : 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.surface,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: compact ? 24 : 28,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


