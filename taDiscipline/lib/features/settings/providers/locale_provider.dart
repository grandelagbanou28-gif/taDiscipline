import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/data/local/app_session.dart';
import 'package:apex/data/repositories/settings_repository.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr'));

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    final userId = AppSession.userId;
    if (userId != null) {
      try {
        final settings = await SettingsRepository().getSettings(userId);
        await SettingsRepository().updateSettings(
          settings.copyWith(language: languageCode),
        );
      } catch (_) {}
    }
  }
}
