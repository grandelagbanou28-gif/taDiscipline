import 'package:flutter_test/flutter_test.dart';
import 'package:apex/core/utils/validators.dart';

void main() {
  group('Validators - Email', () {
    test('email valide', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('email sans @', () {
      expect(Validators.email('testexample.com'), isNotNull);
    });

    test('email vide', () {
      expect(Validators.email(''), isNotNull);
    });

    test('email null', () {
      expect(Validators.email(null), isNotNull);
    });
  });

  group('Validators - Password', () {
    test('password valide', () {
      expect(Validators.password('Motdepasse1'), isNull);
    });

    test('password trop court', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('password sans majuscule', () {
      expect(Validators.password('motdepasse1'), isNotNull);
    });

    test('password sans chiffre', () {
      expect(Validators.password('Motdepasse'), isNotNull);
    });
  });

  group('Validators - PIN', () {
    test('PIN valide', () {
      expect(Validators.pin('123456'), isNull);
    });

    test('PIN trop court', () {
      expect(Validators.pin('123'), isNotNull);
    });

    test('PIN avec lettres', () {
      expect(Validators.pin('12345a'), isNotNull);
    });
  });

  group('Password strength', () {
    test('score bas pour mot court', () {
      expect(Validators.passwordScore('a'), lessThan(50));
    });

    test('score parfait', () {
      expect(Validators.passwordScore('Mot2passe@fort!'), greaterThan(80));
    });
  });
}
