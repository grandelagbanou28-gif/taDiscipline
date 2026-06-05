import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/core/constants/app_constants.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/features/security/services/pin_service.dart';
import 'package:ta_discipline/features/security/services/biometric_service.dart';
import 'package:ta_discipline/data/repositories/auth_repository.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';

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
    final userId = AppSupabase.currentUser?.id;
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
              const SizedBox(height: 40),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    ...List.generate(9, (i) => _NumpadButton(
                      label: '${i + 1}',
                      onTap: () => _onDigit('${i + 1}'),
                    )),
                    const SizedBox.shrink(),
                    _NumpadButton(
                      label: '0',
                      onTap: () => _onDigit('0'),
                    ),
                    _NumpadButton(
                      label: '⌫',
                      onTap: () => _onDelete(),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _skip,
                child: const Text(
                  'Configurer plus tard',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
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

class _NumpadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumpadButton({required this.label, required this.onTap});

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
