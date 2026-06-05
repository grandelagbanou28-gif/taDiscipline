import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/features/security/services/totp_service.dart';

void main() {
  group('TotpService', () {
    test('generateSecret produit une chaîne base32', () {
      final secret = TotpService.generateSecret();
      expect(secret, isNotEmpty);
      expect(RegExp(r'^[A-Z2-7=]+$').hasMatch(secret), isTrue);
    });

    test('generateSecret produit des secrets différents', () {
      final s1 = TotpService.generateSecret();
      final s2 = TotpService.generateSecret();
      expect(s1, isNot(s2));
    });

    test('generateCode produit un code à 6 chiffres', () {
      final secret = TotpService.generateSecret();
      final code = TotpService.generateCode(secret);
      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);
    });

    test('verifyCode valide un code généré', () {
      final secret = TotpService.generateSecret();
      final code = TotpService.generateCode(secret);
      final verified = TotpService.verifyCode(secret, code);
      expect(verified, isTrue);
    });

    test('verifyCode rejette un mauvais code', () {
      final verified = TotpService.verifyCode('JBSWY3DPEHPK3PXP', '000000');
      expect(verified, isFalse);
    });

    test('getProvisioningUri produit un URI valide', () {
      final uri = TotpService.getProvisioningUri('JBSWY3DPEHPK3PXP', 'test@user');
      expect(uri, contains('otpauth://totp/'));
      expect(uri, contains('test@user'));
      expect(uri, contains('JBSWY3DPEHPK3PXP'));
    });
  });
}
