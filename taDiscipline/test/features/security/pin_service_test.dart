import 'package:flutter_test/flutter_test.dart';
import 'package:apex/features/security/services/pin_service.dart';
import 'package:apex/data/repositories/auth_repository.dart';

void main() {
  group('PinService', () {
    test('hashPIN produit un hash prévisible', () {
      final result = PinService.hashPIN('123456');
      expect(result.hash, isNotEmpty);
      expect(result.salt, isNotEmpty);
    });

    test('verifyPIN fonctionne avec le bon PIN', () {
      const pin = '123456';
      final result = PinService.hashPIN(pin);
      final verified = PinService.verifyPIN(pin, result.hash, result.salt);
      expect(verified, isTrue);
    });

    test('verifyPIN rejette le mauvais PIN', () {
      final result = PinService.hashPIN('123456');
      final verified = PinService.verifyPIN('000000', result.hash, result.salt);
      expect(verified, isFalse);
    });

    test('hashPIN produit des hash différents pour des sels différents', () {
      final r1 = PinService.hashPIN('123456');
      final r2 = PinService.hashPIN('123456');
      expect(r1.hash, isNot(r2.hash));
    });
  });
}
