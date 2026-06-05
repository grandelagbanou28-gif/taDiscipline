import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/shared/widgets/app_text_field.dart';
import 'package:ta_discipline/features/auth/providers/auth_provider.dart';
import 'package:ta_discipline/core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé ! Bienvenue sur taDiscipline.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/pin-setup');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Google: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Créer ton compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Prénom / Pseudo',
                  hint: 'Jean',
                  controller: _nameController,
                  validator: (v) => Validators.notEmpty(v, 'Nom'),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Email',
                  hint: 'ton@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Mot de passe',
                  hint: '8 caractères min, 1 majuscule, 1 chiffre',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  onChanged: (_) => setState(() {}),
                  prefixIcon:
                      const Icon(Icons.lock_outlined, color: AppColors.textMuted),
                ),
                PasswordStrengthIndicator(
                  score: Validators.passwordScore(_passwordController.text),
                ),
                const SizedBox(height: 32),
                GlassButton(
                  label: 'Créer mon compte',
                  onPressed: _register,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                        child: Divider(color: AppColors.glassBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const Expanded(
                        child: Divider(color: AppColors.glassBorder)),
                  ],
                ),
                const SizedBox(height: 24),
                _OAuthButton(
                  icon: Icons.g_mobiledata,
                  label: 'Continuer avec Google',
                  onPressed: _signInWithGoogle,
                  iconColor: const Color(0xFF4285F4),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Déjà un compte ? Connecte-toi',
                    style: TextStyle(color: AppColors.primaryLight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color iconColor;

  const _OAuthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 22),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.glassBorder),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
