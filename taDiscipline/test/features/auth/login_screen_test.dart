import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen affiche les champs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Apex'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('LoginScreen bouton connexion désactivé si champs vides',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
    for (final button in buttons) {
      if (button.child is Text &&
          (button.child as Text).data == 'Se connecter') {
        expect(button.onPressed, isNull);
      }
    }
  });
}
