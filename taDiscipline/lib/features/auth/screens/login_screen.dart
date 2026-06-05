import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ta_discipline/core/theme/app_colors.dart';
import 'package:ta_discipline/shared/widgets/glass_card.dart';
import 'package:ta_discipline/shared/widgets/app_text_field.dart';
import 'package:ta_discipline/features/auth/providers/auth_provider.dart';
import 'package:ta_discipline/core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
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

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Apple: ${e.toString()}'),
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
                const SizedBox(height: 60),
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
                const SizedBox(height: 4),
                const Text(
                  'Maîtrise ton quotidien, conquiers tes rêves.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
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
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  validator: Validators.password,
                  prefixIcon:
                      const Icon(Icons.lock_outlined, color: AppColors.textMuted),
                ),
                const SizedBox(height: 32),
                GlassButton(
                  label: 'Se connecter',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.glassBorder)),
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
                    const Expanded(child: Divider(color: AppColors.glassBorder)),
                  ],
                ),
                const SizedBox(height: 24),
                _OAuthButton(
                  icon: Icons.g_mobiledata,
                  label: 'Continuer avec Google',
                  onPressed: _signInWithGoogle,
                  iconColor: const Color(0xFF4285F4),
                ),
                const SizedBox(height: 12),
                _OAuthButton(
                  icon: Icons.apple,
                  label: 'Continuer avec Apple',
                  onPressed: _signInWithApple,
                  iconColor: AppColors.textPrimary,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text(
                    'Créer un compte',
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
