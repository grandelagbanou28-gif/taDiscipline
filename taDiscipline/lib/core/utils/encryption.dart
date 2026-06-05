import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';

class EncryptionService {
  EncryptionService._();

  static Future<encrypt.Key> _deriveKey(String password) async {
    final keyBytes = utf8.encode(password.padRight(32).substring(0, 32));
    return encrypt.Key.fromUtf8(utf8.decode(keyBytes));
  }

  static Future<String> encryptText({
    required String plainText,
    required String secretKey,
  }) async {
    try {
      final key = await _deriveKey(secretKey);
      final iv = encrypt.IV.fromSecureRandom(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final combined = Uint8List.fromList([
        ...iv.bytes,
        ...encrypted.bytes,
      ]);
      return base64.encode(combined);
    } catch (e) {
      debugPrint('Erreur chiffrement: $e');
      rethrow;
    }
  }

  static Future<String> decryptText({
    required String encryptedBase64,
    required String secretKey,
  }) async {
    try {
      final key = await _deriveKey(secretKey);
      final combined = base64.decode(encryptedBase64);
      final iv = encrypt.IV(Uint8List.fromList(combined.sublist(0, 16)));
      final encryptedBytes = Uint8List.fromList(combined.sublist(16));
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypt.Encrypted(encryptedBytes);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      return decrypted;
    } catch (e) {
      debugPrint('Erreur déchiffrement: $e');
      rethrow;
    }
  }

  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String hashPassword(String password, String salt) {
    final combined = '$password:$salt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }
}
