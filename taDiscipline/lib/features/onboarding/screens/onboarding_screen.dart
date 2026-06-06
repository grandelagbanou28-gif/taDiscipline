import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/features/security/services/pin_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';
import 'package:apex/data/local/app_session.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkExistingPin();
  }

  Future<void> _checkExistingPin() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    final service = PinService(AuthRepository());
    await service.initialize(userId);
    if (service.hasPin && mounted) {
      context.go('/pin-unlock');
    }
  }

  final _steps = [
    _OnboardingStep(
      icon: Icons.flag_rounded,
      title: 'Définis tes objectifs',
      description:
          'Crée des objectifs SMART, décompose-les en sous-tâches\n'
          'et suis ta progression visuellement.',
      color: AppColors.primary,
    ),
    _OnboardingStep(
      icon: Icons.repeat_rounded,
      title: 'Construis des habitudes',
      description:
          'Des petites actions quotidiennes qui deviennent\n'
          'automatiques. La clé de la discipline.',
      color: AppColors.success,
    ),
    _OnboardingStep(
      icon: Icons.calendar_month_rounded,
      title: 'Planifie ta semaine',
      description:
          'Organise tes journées, priorise tes tâches\n'
          'et ne laisse rien au hasard.',
      color: AppColors.accent,
    ),
    _OnboardingStep(
      icon: Icons.auto_awesome_rounded,
      title: 'Apex IA',
      description:
          'Un assistant propulsé par Grok (xAI)\n'
          'qui répond à toutes tes questions au quotidien.',
      color: AppColors.cyan,
    ),
    _OnboardingStep(
      icon: Icons.shield_rounded,
      title: 'Sécurisé & Privé',
      description:
          'PIN, biométrie, chiffrement AES-256.\n'
          'Tes données t\'appartiennent.',
      color: AppColors.magenta,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: step.color.withValues(alpha: 0.15),
                          ),
                          child: Icon(step.icon, color: step.color, size: 48),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontFamily: 'Space Grotesk',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Indicateurs
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? _steps[i].color
                        : AppColors.glassBorder,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Boutons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  GlassButton(
                    label: _currentPage == _steps.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    onPressed: () {
                      if (_currentPage == _steps.length - 1) {
                        context.go('/pin-setup');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage < _steps.length - 1)
                    TextButton(
                      onPressed: () => context.go('/pin-setup'),
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
