import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:apex/shared/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard affiche le child', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassCard(
            child: Text('Test Content'),
          ),
        ),
      ),
    );
    expect(find.text('Test Content'), findsOneWidget);
  });

  testWidgets('GlassCard réagit au tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassCard(
            onTap: () => tapped = true,
            child: const Text('Tap me'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tap me'));
    expect(tapped, isTrue);
  });

  testWidgets('GlassButton disabled when loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassButton(
            label: 'Chargement...',
            isLoading: true,
          ),
        ),
      ),
    );
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });
}
