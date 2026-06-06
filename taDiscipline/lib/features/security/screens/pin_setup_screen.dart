import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/features/security/services/pin_service.dart';
import 'package:apex/features/security/services/biometric_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';
import 'package:apex/data/local/app_session.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showConfirm = false;
  bool _useBiometric = false;
  late PinService _pinService;
  late BiometricService _biometricService;

  @override
  void initState() {
    super.initState();
    _pinService = PinService(AuthRepository());
    _biometricService = BiometricService(AuthRepository());
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _biometricService.isBiometricAvailable;
    if (mounted) setState(() => _useBiometric = available);
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onPinEntered(String pin) {
    if (pin.length != 6) return;
    if (!_showConfirm) {
      _pinController.text = pin;
      setState(() => _showConfirm = true);
    } else {
      if (pin == _pinController.text) {
        _savePin(pin);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les codes PIN ne correspondent pas'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _showConfirm = false;
          _pinController.clear();
          _confirmController.clear();
        });
      }
    }
  }

  Future<void> _savePin(String pin) async {
    final userId = AppSession.userId;
    if (userId == null) return;

    await _pinService.setPin(userId, pin);

    if (_useBiometric) {
      final authenticated = await _biometricService.authenticate(
        reason: 'Active la biométrie pour déverrouiller l\'app',
      );
      if (authenticated) {
        await _biometricService.enableBiometric(userId);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sécurité configurée ✅'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/dashboard');
    }
  }

  void _skip() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _showConfirm ? _confirmController.text : _pinController.text;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryLight,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _showConfirm ? 'Confirme ton code PIN' : 'Crée un code PIN',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Code à 6 chiffres pour déverrouiller l\'app',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < currentPin.length;
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
              const Spacer(),
              _Numpad(
                onDigit: _onDigit,
                onDelete: _onDelete,
              ),
              const Spacer(),
              TextButton(
                onPressed: _skip,
                child: const Text(
                  'Configurer plus tard',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onDigit(String digit) {
    if (_showConfirm) {
      if (_confirmController.text.length < 6) {
        _confirmController.text += digit;
        _onPinEntered(_confirmController.text);
      }
    } else {
      if (_pinController.text.length < 6) {
        _pinController.text += digit;
        if (_pinController.text.length == 6) {
          _onPinEntered(_pinController.text);
        }
      }
    }
  }

  void _onDelete() {
    if (_showConfirm) {
      if (_confirmController.text.isNotEmpty) {
        _confirmController.text = _confirmController.text
            .substring(0, _confirmController.text.length - 1);
      }
    } else {
      if (_pinController.text.isNotEmpty) {
        _pinController.text = _pinController.text
            .substring(0, _pinController.text.length - 1);
      }
    }
    setState(() {});
  }
}

class _Numpad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onDelete;

  const _Numpad({required this.onDigit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NumpadRow(
          children: ['1', '2', '3'],
          onDigit: onDigit,
        ),
        const SizedBox(height: 12),
        _NumpadRow(
          children: ['4', '5', '6'],
          onDigit: onDigit,
        ),
        const SizedBox(height: 12),
        _NumpadRow(
          children: ['7', '8', '9'],
          onDigit: onDigit,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 76),
            _NumpadKey(label: '0', onTap: () => onDigit('0')),
            const SizedBox(width: 12),
            _NumpadKey(label: '⌫', onTap: onDelete),
          ],
        ),
      ],
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> children;
  final void Function(String) onDigit;

  const _NumpadRow({required this.children, required this.onDigit});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children.map((label) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _NumpadKey(label: label, onTap: () => onDigit(label)),
        );
      }).toList(),
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
          width: 76,
          height: 56,
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
