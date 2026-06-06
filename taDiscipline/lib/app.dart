import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/constants/app_constants.dart';
import 'package:apex/core/theme/app_theme.dart';
import 'package:apex/core/theme/app_colors.dart';
import 'package:apex/core/router/app_router.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/repositories/settings_repository.dart';
import 'package:apex/features/auth/providers/auth_provider.dart';
import 'package:apex/features/security/services/auto_lock_service.dart';
import 'package:apex/features/security/services/panic_service.dart';
import 'package:apex/features/security/screens/pin_unlock_screen.dart';
import 'package:apex/features/settings/providers/locale_provider.dart';
import 'package:apex/l10n/app_localizations.dart';

class ApexApp extends ConsumerStatefulWidget {
  const ApexApp({super.key});

  @override
  ConsumerState<ApexApp> createState() => _ApexAppState();
}

class _ApexAppState extends ConsumerState<ApexApp>
    with WidgetsBindingObserver {
  late AutoLockService _autoLockService;
  late PanicService _panicService;
  bool _showLockScreen = false;
  bool _panicMode = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _autoLockService = AutoLockService(onAutoLock: _onAutoLock);
    _panicService = PanicService();
    _panicService.initialize(_onPanicToggle);
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await ref.read(authProvider.notifier).tryRestoreSession();
    final userId = AppSession.userId;
    if (userId != null) {
      try {
        final settings = await SettingsRepository().getSettings(userId);
        if (mounted) ref.read(localeProvider.notifier).setLocale(settings.language);
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _autoLockService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    AppSession.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _autoLockService.start();
    } else if (state == AppLifecycleState.resumed) {
      _autoLockService.resetTimer();
    }
  }

  void _onAutoLock() {
    if (mounted) setState(() => _showLockScreen = true);
  }

  void _onPanicToggle() {
    setState(() => _panicMode = !_panicMode);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return Listener(
      onPointerDown: (_) => _autoLockService.resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: MaterialApp.router(
        title: AppConstants.appName,
        locale: locale,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          if (!_initialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }
          if (_showLockScreen) {
            return PinUnlockScreen(
              onUnlock: () {
                _autoLockService.unlock();
                setState(() => _showLockScreen = false);
              },
            );
          }
          if (_panicMode) {
            return _PanicOverlay(child: child!);
          }
          return child!;
        },
      ),
    );
  }
}

class _PanicOverlay extends StatelessWidget {
  final Widget child;
  const _PanicOverlay({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Container(
          color: AppColors.background,
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: AppColors.textMuted, size: 48),
                SizedBox(height: 16),
                Text(
                  'Mode privé activé',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Double-tap pour réactiver',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
