import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/features/security/services/pin_service.dart';
import 'package:apex/features/security/services/biometric_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';
import 'package:apex/data/local/app_session.dart';

enum _PinStep { oldPin, newPin, confirmPin }

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pinController = TextEditingController();
  String? _newPin;
  _PinStep _step = _PinStep.newPin;
  bool _useBiometric = false;
  late PinService _pinService;
  late BiometricService _biometricService;

  @override
  void initState() {
    super.initState();
    _pinService = PinService(AuthRepository());
    _biometricService = BiometricService(AuthRepository());
    _init();
  }

  Future<void> _init() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    await _pinService.initialize(userId);
    await _checkBiometricAvailability();
    if (mounted) {
      setState(() {
        _step = _pinService.hasPin ? _PinStep.oldPin : _PinStep.newPin;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final available = await _biometricService.isBiometricAvailable;
    if (mounted) setState(() => _useBiometric = available);
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  String get _title {
    switch (_step) {
      case _PinStep.oldPin:
        return 'Entre ton code PIN actuel';
      case _PinStep.newPin:
        return 'Nouveau code PIN';
      case _PinStep.confirmPin:
        return 'Confirme le nouveau code PIN';
    }
  }

  String get _subtitle {
    switch (_step) {
      case _PinStep.oldPin:
        return '6 chiffres requis';
      case _PinStep.newPin:
        return '6 chiffres pour déverrouiller l\'app';
      case _PinStep.confirmPin:
        return 'Ressaisis le code à 6 chiffres';
    }
  }

  Future<void> _onConfirm() async {
    final pin = _pinController.text;
    if (pin.length != 6) return;

    switch (_step) {
      case _PinStep.oldPin:
        final valid = await _pinService.verifyPin(pin);
        if (valid) {
          _pinController.clear();
          setState(() => _step = _PinStep.newPin);
        } else {
          _pinController.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Code PIN incorrect'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
        break;
      case _PinStep.newPin:
        _newPin = pin;
        _pinController.clear();
        setState(() => _step = _PinStep.confirmPin);
        break;
      case _PinStep.confirmPin:
        if (pin == _newPin) {
          await _savePin(pin);
        } else {
          _pinController.clear();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Les codes PIN ne correspondent pas'),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _step = _PinStep.newPin);
          }
        }
        break;
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
          content: Text('Code PIN enregistré ✅'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  void _skip() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentPin = _pinController.text;
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: compact ? 56 : 64,
                height: compact ? 56 : 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryLight,
                  size: compact ? 28 : 32,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                _title,
                style: TextStyle(
                  fontSize: compact ? 20 : 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              SizedBox(height: compact ? 6 : 8),
              Text(
                _subtitle,
                style: TextStyle(
                  fontSize: compact ? 13 : 14,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: compact ? 24 : 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < currentPin.length;
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
                pinLength: currentPin.length,
                onDigit: _onDigit,
                onDelete: _onDelete,
                onConfirm: currentPin.length == 6 ? _onConfirm : null,
              ),
              const SizedBox(height: 16),
              if (_step == _PinStep.oldPin || _step == _PinStep.newPin)
                TextButton(
                  onPressed: _skip,
                  child: Text(
                    _step == _PinStep.oldPin ? 'Annuler' : 'Configurer plus tard',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              SizedBox(height: compact ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onDigit(String digit) {
    if (_pinController.text.length < 6) {
      _pinController.text += digit;
      setState(() {});
    }
  }

  void _onDelete() {
    if (_pinController.text.isNotEmpty) {
      _pinController.text = _pinController.text
          .substring(0, _pinController.text.length - 1);
      setState(() {});
    }
  }
}

class _Numpad extends StatelessWidget {
  final bool compact;
  final int pinLength;
  final void Function(String) onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onConfirm;

  const _Numpad({
    this.compact = false,
    this.pinLength = 0,
    required this.onDigit,
    required this.onDelete,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NumpadRow(
          children: ['1', '2', '3'],
          compact: compact,
          onDigit: onDigit,
        ),
        SizedBox(height: compact ? 8 : 12),
        _NumpadRow(
          children: ['4', '5', '6'],
          compact: compact,
          onDigit: onDigit,
        ),
        SizedBox(height: compact ? 8 : 12),
        _NumpadRow(
          children: ['7', '8', '9'],
          compact: compact,
          onDigit: onDigit,
        ),
        SizedBox(height: compact ? 8 : 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _NumpadKey(label: '⌫', compact: compact, onTap: onDelete),
            SizedBox(width: compact ? 8 : 12),
            _NumpadKey(label: '0', compact: compact, onTap: () => onDigit('0')),
            SizedBox(width: compact ? 8 : 12),
            _NumpadKey(
              label: 'OK',
              compact: compact,
              onTap: onConfirm ?? () {},
              highlight: pinLength == 6,
            ),
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
          child: _NumpadKey(
            label: label,
            compact: compact,
            onTap: () => onDigit(label),
          ),
        );
      }).toList(),
    );
  }
}

class _NumpadKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool compact;
  final bool highlight;

  const _NumpadKey({
    required this.label,
    required this.onTap,
    this.compact = false,
    this.highlight = false,
  });

  @override
  State<_NumpadKey> createState() => _NumpadKeyState();
}

class _NumpadKeyState extends State<_NumpadKey> {
  bool _pressed = false;

  Color get _bgColor {
    if (_pressed) return AppColors.primary.withValues(alpha: 0.3);
    if (widget.highlight) return AppColors.primary.withValues(alpha: 0.2);
    return AppColors.surface;
  }

  Color get _borderColor {
    if (_pressed || widget.highlight) return AppColors.primary;
    return AppColors.glassBorder;
  }

  Color get _textColor {
    if (_pressed || widget.highlight) return AppColors.primary;
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.compact ? 64 : 76,
        height: widget.compact ? 48 : 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _bgColor,
          border: Border.all(color: _borderColor),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: widget.compact ? 24 : 28,
              fontWeight: widget.highlight ? FontWeight.w700 : FontWeight.w500,
              color: _textColor,
            ),
          ),
        ),
      ),
    );
  }
}
