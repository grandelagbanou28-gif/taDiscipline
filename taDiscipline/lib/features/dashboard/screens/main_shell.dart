import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex(context),
          onTap: (index) => _onTab(context, index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Tableau',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag),
              label: 'Objectifs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.repeat_outlined),
              activeIcon: Icon(Icons.repeat),
              label: 'Habitudes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Planning',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'chat',
        onPressed: () => context.push('/chat'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome, color: AppColors.textPrimary),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/habits')) return 2;
    if (location.startsWith('/plans')) return 3;
    if (location.startsWith('/statistics')) return 4;
    return 0;
  }

  void _onTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/goals');
      case 2:
        context.go('/habits');
      case 3:
        context.go('/plans');
      case 4:
        context.go('/statistics');
    }
  }
}
