import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:apex/shared/widgets/animated_circular_progress.dart';

void main() {
  testWidgets('AnimatedCircularProgress affiche le centerText',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCircularProgress(
            progress: 0.5,
            size: 100,
            centerText: '50%',
          ),
        ),
      ),
    );
    expect(find.text('50%'), findsOneWidget);
  });

  testWidgets('AnimatedCircularProgress avec progress 0', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCircularProgress(
            progress: 0.0,
            size: 100,
          ),
        ),
      ),
    );
    // ne devrait pas planter
    expect(find.byType(AnimatedCircularProgress), findsOneWidget);
  });

  testWidgets('AnimatedCircularProgress avec progress 1.0', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedCircularProgress(
            progress: 1.0,
            size: 100,
          ),
        ),
      ),
    );
    expect(find.byType(AnimatedCircularProgress), findsOneWidget);
  });
}
