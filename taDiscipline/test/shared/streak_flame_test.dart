import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ta_discipline/shared/widgets/streak_flame.dart';

void main() {
  testWidgets('StreakFlame affiche le count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakFlame(count: 15, size: 40),
        ),
      ),
    );
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('StreakFlame avec count 0', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakFlame(count: 0, size: 40),
        ),
      ),
    );
    expect(find.byType(StreakFlame), findsOneWidget);
  });

  testWidgets('StreakFlame ne plante pas sans size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StreakFlame(count: 7),
        ),
      ),
    );
    expect(find.byType(StreakFlame), findsOneWidget);
  });
}
