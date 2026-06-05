import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ta_discipline/app.dart';
import 'package:ta_discipline/data/supabase/supabase_client.dart';
import 'package:ta_discipline/core/constants/app_constants.dart';
import 'package:ta_discipline/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await AppSupabase.initialize();
    await NotificationService().initialize();
    if (kDebugMode) {
      debugPrint('✅ Supabase connecté : ${AppConstants.supabaseUrl}');
    }
  } catch (e) {
    debugPrint('⚠️  Supabase non configuré. Utilise --dart-define '
        'ou édite .env pour renseigner SUPABASE_URL et SUPABASE_ANON_KEY.\n'
        'Erreur : $e');
  }

  runApp(
    const ProviderScope(
      child: TaDisciplineApp(),
    ),
  );
}
