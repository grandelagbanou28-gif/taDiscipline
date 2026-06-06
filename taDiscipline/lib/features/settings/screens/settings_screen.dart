import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/shared/widgets/verified_badge.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/models/user_profile.dart';
import 'package:apex/data/repositories/settings_repository.dart';
import 'package:apex/data/models/journal_entry.dart';
import 'package:apex/features/auth/providers/auth_provider.dart';
import 'package:apex/features/settings/providers/verified_provider.dart';
import 'package:apex/features/security/services/biometric_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';

final userSettingsProvider = FutureProvider<UserSettings>((ref) {
  final userId = AppSession.userId;
  if (userId == null) throw Exception('Non connecté');
  return SettingsRepository().getSettings(userId);
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  int _lockTimeout = 2;
  bool _biometricEnabled = false;
  bool _sleepResetEnabled = false;
  String? _sleepTime;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    try {
      final settings = await SettingsRepository().getSettings(userId);
      final profile = ref.read(authProvider).valueOrNull;
      if (mounted) {
        setState(() {
          _notificationsEnabled = settings.notificationsEnabled;
          _lockTimeout = settings.lockTimeoutMinutes;
          _biometricEnabled = profile?.biometricEnabled ?? false;
          _sleepResetEnabled = settings.sleepResetEnabled;
          _sleepTime = settings.sleepTime ?? '22:00';
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleBiometric(bool value) async {
    final userId = AppSession.userId;
    if (userId == null) return;

    if (value) {
      final bio = BiometricService(AuthRepository());
      final authenticated = await bio.authenticate(
        reason: 'Activer la biométrie',
      );
      if (authenticated) {
        await bio.enableBiometric(userId);
        setState(() => _biometricEnabled = true);
      }
    } else {
      await BiometricService(AuthRepository()).disableBiometric(userId);
      setState(() => _biometricEnabled = false);
    }
  }

  Future<void> _changePin() async {
    context.push('/pin-setup');
  }

  Future<void> _pickSleepTime() async {
    final parts = (_sleepTime ?? '22:00').split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 22,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => _sleepTime = timeStr);
      final userId = AppSession.userId;
      if (userId == null) return;
      final settings = await SettingsRepository().getSettings(userId);
      await SettingsRepository().updateSettings(
        settings.copyWith(sleepTime: timeStr),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authProvider).valueOrNull;
    final isVerified = ref.watch(verifiedProvider).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitial(profile),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _getDisplayName(profile),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            const VerifiedBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Membre depuis ${profile?.createdAt.day ?? "..."}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sécurité
          const Text(
            'Sécurité',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.lock_outline,
                  title: 'Code PIN',
                  subtitle: 'Verrouillage rapide à 6 chiffres',
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onPressed: _changePin,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.fingerprint,
                  title: 'Biométrie',
                  subtitle: 'Face ID / Touch ID',
                  trailing: Switch(
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                    activeColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.timer_outlined,
                  title: 'Verrouillage auto',
                  subtitle: 'Après $_lockTimeout min d\'inactivité',
                  trailing: DropdownButton<int>(
                    value: _lockTimeout,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.surface,
                    style: const TextStyle(color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 min')),
                      DropdownMenuItem(value: 2, child: Text('2 min')),
                      DropdownMenuItem(value: 5, child: Text('5 min')),
                      DropdownMenuItem(value: 10, child: Text('10 min')),
                    ],
                    onChanged: (v) async {
                      if (v == null) return;
                      setState(() => _lockTimeout = v);
                      final userId = AppSession.userId;
                      if (userId == null) return;
                      final settings = await SettingsRepository()
                          .getSettings(userId);
                      await SettingsRepository().updateSettings(
                        settings.copyWith(lockTimeoutMinutes: v),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: _SettingTile(
              icon: Icons.notifications_outlined,
              title: 'Rappels',
              subtitle: 'Notifications push',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) async {
                  setState(() => _notificationsEnabled = v);
                  final userId = AppSession.userId;
                  if (userId == null) return;
                  final settings =
                      await SettingsRepository().getSettings(userId);
                  await SettingsRepository().updateSettings(
                    settings.copyWith(notificationsEnabled: v),
                  );
                },
                activeColor: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mode Sommeil
          const Text(
            'Mode Sommeil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.bedtime_outlined,
                  title: 'Mode Sommeil',
                  subtitle: 'Réinitialisation quotidienne après l\'heure',
                  trailing: Switch(
                    value: _sleepResetEnabled,
                    onChanged: (v) async {
                      setState(() => _sleepResetEnabled = v);
                      final userId = AppSession.userId;
                      if (userId == null) return;
                      final settings =
                          await SettingsRepository().getSettings(userId);
                      await SettingsRepository().updateSettings(
                        settings.copyWith(sleepResetEnabled: v),
                      );
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                if (_sleepResetEnabled) ...[
                  const Divider(height: 1),
                  _SettingTile(
                    icon: Icons.schedule,
                    title: 'Heure du coucher',
                    subtitle: _sleepTime ?? '22:00',
                    trailing: IconButton(
                      icon: const Icon(Icons.edit,
                          color: AppColors.textMuted),
                      onPressed: _pickSleepTime,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Apparence
          const Text(
            'Apparence',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              children: [
                _SettingTile(
                  icon: Icons.dark_mode,
                  title: 'Mode sombre',
                  subtitle: 'Thème sombre par défaut',
                  trailing: Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.notifications_active,
                  title: 'Pings intelligents',
                  subtitle: 'Rituels et rappels contextuels',
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onPressed: () => context.push('/settings/pings'),
                  ),
                ),
                const Divider(height: 1),
                _SettingTile(
                  icon: Icons.widgets_outlined,
                  title: 'Widget',
                  subtitle: 'Widget écran d\'accueil',
                  trailing: IconButton(
                    icon: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                    onPressed: () => context.push('/settings/widget-config'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.error.withValues(alpha: 0.15),
            ),
            child: TextButton.icon(
              onPressed: () async {
                await AppSession.signOut();
                if (mounted) context.go('/onboarding');
              },
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Déconnexion',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getDisplayName(UserProfile? profile) {
    if (profile?.displayName.isNotEmpty == true) return profile!.displayName;
    return 'Utilisateur';
  }

  String _getInitial(UserProfile? profile) {
    final name = _getDisplayName(profile);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary, size: 22),
        title: Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: trailing,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
