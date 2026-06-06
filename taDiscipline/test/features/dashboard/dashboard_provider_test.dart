import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/features/dashboard/providers/dashboard_provider.dart';

void main() {
  group('DashboardProvider (non-Supabase)', () {
    test('dashboardProvider existe et est un FutureProvider', () {
      expect(dashboardProvider, isA<FutureProvider<DashboardData>>());
    });
  });
}
