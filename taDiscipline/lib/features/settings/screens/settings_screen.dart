import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/shared/widgets/glass_card.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/models/user_profile.dart';
import 'package:apex/data/repositories/settings_repository.dart';
import 'package:apex/data/models/journal_entry.dart';
import 'package:apex/features/auth/providers/auth_provider.dart';
import 'package:apex/features/settings/providers/locale_provider.dart';

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
  bool _sleepResetEnabled = false;
  String? _sleepTime;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _avatarPath;

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
          _sleepResetEnabled = settings.sleepResetEnabled;
          _sleepTime = settings.sleepTime ?? '22:00';
          _firstNameController.text = profile?.firstName ?? '';
          _lastNameController.text = profile?.lastName ?? '';
          _avatarPath = profile?.avatarUrl;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (file != null) {
      setState(() => _avatarPath = file.path);
    }
  }

  Future<void> _saveProfile() async {
    final userId = AppSession.userId;
    if (userId == null) return;
    await AppSession.updateProfileNameAndPhoto(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      avatarUrl: _avatarPath,
    );
    ref.invalidate(authProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil mis à jour ✅'), backgroundColor: AppColors.success),
      );
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

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: _avatarPath == null
                                ? const LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryDark],
                                  )
                                : null,
                            image: _avatarPath != null
                                ? DecorationImage(
                                    image: FileImage(File(_avatarPath!)),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _avatarPath == null
                              ? Center(
                                  child: Text(
                                    _getInitial(profile),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                            child: const Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _firstNameController,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      labelStyle: TextStyle(color: AppColors.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _lastNameController,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: AppColors.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.glassBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                      ),
                      child: TextButton(
                        onPressed: _saveProfile,
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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

          // Langue
          const Text(
            'Langue / Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: _SettingTile(
              icon: Icons.language,
              title: 'Langue',
              subtitle: 'Français / English / Русский',
              trailing: DropdownButton<String>(
                value: ref.watch(localeProvider).languageCode,
                underline: const SizedBox(),
                dropdownColor: AppColors.surface,
                style: const TextStyle(color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ru', child: Text('Русский')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(localeProvider.notifier).setLocale(v);
                  }
                },
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

  String _getInitial(UserProfile? profile) {
    if (profile?.firstName?.isNotEmpty == true) return profile!.firstName![0].toUpperCase();
    if (profile?.lastName?.isNotEmpty == true) return profile!.lastName![0].toUpperCase();
    return '?';
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
