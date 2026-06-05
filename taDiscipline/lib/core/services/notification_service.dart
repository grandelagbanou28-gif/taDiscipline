import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ta_discipline/core/constants/app_constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'tadiscipline_channel',
      'taDiscipline',
      channelDescription: 'Rappels et notifications de l\'application',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'tadiscipline_daily',
      'Rappels quotidiens',
      channelDescription: 'Rappels quotidiens pour tes objectifs',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.daily,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showPomodoroComplete() async {
    await showNotification(
      id: 100,
      title: '🎯 Pomodoro terminé !',
      body: 'Prends une pause de ${AppConstants.shortBreakMinutes} minutes.',
    );
  }

  Future<void> showGoalReminder(String goalTitle) async {
    await showNotification(
      id: 200,
      title: '📌 Rappel d\'objectif',
      body: 'N\'oublie pas ton objectif : $goalTitle',
    );
  }

  Future<void> showHabitReminder(String habitName) async {
    await showNotification(
      id: 300,
      title: '🔄 Ton habitude du jour',
      body: 'Il est temps de : $habitName',
    );
  }

  Future<void> showStreakCelebration(int streak) async {
    await showNotification(
      id: 400,
      title: '🔥 $streak jours consécutifs !',
      body: 'Continue comme ça, tu assures !',
    );
  }
}
