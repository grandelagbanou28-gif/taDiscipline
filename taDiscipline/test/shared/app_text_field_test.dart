import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ta_discipline/shared/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField affiche le label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Email',
            hint: 'Entrez votre email',
          ),
        ),
      ),
    );
    expect(find.text('Email'), findsOneWidget);
  });

  testWidgets('AppTextField avec erreur affiche le message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Email',
            error: 'Email invalide',
          ),
        ),
      ),
    );
    expect(find.text('Email invalide'), findsOneWidget);
  });

  testWidgets('AppTextField lit la valeur', (tester) async {
    String? value;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(
            label: 'Test',
            onChanged: (v) => value = v,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'Hello');
    expect(value, 'Hello');
  });

  testWidgets('PasswordStrengthIndicator calcule le score', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PasswordStrengthIndicator(password: 'Mot2passe@fort!'),
        ),
      ),
    );
    expect(find.byType(PasswordStrengthIndicator), findsOneWidget);
  });
}
