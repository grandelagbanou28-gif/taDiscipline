import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('⚠️ Notification init error: $e');
  }

  runApp(
    const ProviderScope(
      child: ApexApp(),
    ),
  );
}
