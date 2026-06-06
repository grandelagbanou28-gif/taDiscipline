import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/features/onboarding/screens/onboarding_screen.dart';
import 'package:apex/features/security/screens/pin_setup_screen.dart';
import 'package:apex/features/security/screens/pin_unlock_screen.dart';
import 'package:apex/features/dashboard/screens/main_shell.dart';
import 'package:apex/features/dashboard/screens/dashboard_screen.dart';
import 'package:apex/features/goals/screens/goals_screen.dart';
import 'package:apex/features/goals/screens/goal_detail_screen.dart';
import 'package:apex/features/goals/screens/goal_create_screen.dart';
import 'package:apex/features/habits/screens/habits_screen.dart';
import 'package:apex/features/habits/screens/habit_create_screen.dart';
import 'package:apex/features/challenges/screens/challenges_screen.dart';
import 'package:apex/features/challenges/screens/challenge_create_screen.dart';
import 'package:apex/features/challenges/screens/challenge_detail_screen.dart';
import 'package:apex/features/plans/screens/plans_screen.dart';
import 'package:apex/features/journal/screens/journal_screen.dart';
import 'package:apex/features/pomodoro/screens/pomodoro_screen.dart';
import 'package:apex/features/statistics/screens/statistics_screen.dart';
import 'package:apex/features/chat/screens/chat_screen.dart';
import 'package:apex/features/settings/screens/settings_screen.dart';
import 'package:apex/features/settings/screens/ping_schedule_screen.dart';
import 'package:apex/features/widget/screens/widget_config_screen.dart';
import 'package:apex/features/search/screens/search_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/pin-setup',
      name: 'pinSetup',
      builder: (context, state) => const PinSetupScreen(),
    ),
    GoRoute(
      path: '/pin-unlock',
      name: 'pinUnlock',
      builder: (context, state) => PinUnlockScreen(
        onUnlock: () => GoRouter.of(context).go('/dashboard'),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'pings',
          name: 'pings',
          builder: (context, state) => const PingScheduleScreen(),
        ),
        GoRoute(
          path: 'widget-config',
          name: 'widgetConfig',
          builder: (context, state) => const WidgetConfigScreen(),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/goals',
          name: 'goals',
          builder: (context, state) => const GoalsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'goalCreate',
              builder: (context, state) => const GoalCreateScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'goalDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return GoalDetailScreen(goalId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/challenges',
          name: 'challenges',
          builder: (context, state) => const ChallengesScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'challengeCreate',
              builder: (context, state) => const ChallengeCreateScreen(),
            ),
            GoRoute(
              path: ':id',
              name: 'challengeDetail',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ChallengeDetailScreen(challengeId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/habits',
          name: 'habits',
          builder: (context, state) => const HabitsScreen(),
          routes: [
            GoRoute(
              path: 'create',
              name: 'habitCreate',
              builder: (context, state) => const HabitCreateScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/plans',
          name: 'plans',
          builder: (context, state) => const PlansScreen(),
        ),
        GoRoute(
          path: '/journal',
          name: 'journal',
          builder: (context, state) => const JournalScreen(),
        ),
        GoRoute(
          path: '/pomodoro',
          name: 'pomodoro',
          builder: (context, state) => const PomodoroScreen(),
        ),
        GoRoute(
          path: '/statistics',
          name: 'statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat',
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
      ],
    ),
  ],
);
