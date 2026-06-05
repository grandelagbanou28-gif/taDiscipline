import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/core/utils/encryption.dart';

void main() {
  group('EncryptionService', () {
    test('hashPassword produit un hash', () {
      final hash = EncryptionService.hashPassword('123456', 'testsalt');
      expect(hash, isNotEmpty);
      expect(hash.length, 64); // SHA-256 hex
    });

    test('même password + salt donne même hash', () {
      final hash1 = EncryptionService.hashPassword('123456', 'testsalt');
      final hash2 = EncryptionService.hashPassword('123456', 'testsalt');
      expect(hash1, hash2);
    });

    test('password différent donne hash différent', () {
      final hash1 = EncryptionService.hashPassword('123456', 'salt');
      final hash2 = EncryptionService.hashPassword('654321', 'salt');
      expect(hash1, isNot(hash2));
    });

    test('generateSalt produit une chaîne non vide', () {
      final salt = EncryptionService.generateSalt();
      expect(salt, isNotEmpty);
    });

    test('generateSalt produit des valeurs différentes', () {
      final salt1 = EncryptionService.generateSalt();
      final salt2 = EncryptionService.generateSalt();
      expect(salt1, isNot(salt2));
    });

    test('hashSha256 produit un hash non vide', () {
      final hash = EncryptionService.hashSha256('test');
      expect(hash, isNotEmpty);
    });
  });
}
