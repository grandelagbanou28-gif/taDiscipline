import 'dart:convert';
import 'package:crypto/crypto.dart';

class TotpService {
  static const int _timeStepSeconds = 30;
  static const int _codeLength = 6;

  static String generateSecret() {
    final random = List<int>.generate(20, (_) => DateTime.now().microsecondsSinceEpoch % 256);
    final hash = sha256.convert(random).toString();
    return base32Encode(hash.substring(0, 20));
  }

  static String generateTOTP(String secret) {
    final timeCounter = (DateTime.now().millisecondsSinceEpoch / 1000 / _timeStepSeconds).floor();
    final counter = List<int>.generate(8, (i) => (timeCounter >> (8 * (7 - i))) & 0xFF);
    final key = base32Decode(secret);
    final hmacSha1 = Hmac(sha1, key).convert(counter);
    final offset = hmacSha1.bytes[hmacSha1.bytes.length - 1] & 0xF;
    final binaryCode = ((hmacSha1.bytes[offset] & 0x7F) << 24) |
        ((hmacSha1.bytes[offset + 1] & 0xFF) << 16) |
        ((hmacSha1.bytes[offset + 2] & 0xFF) << 8) |
        (hmacSha1.bytes[offset + 3] & 0xFF);
    final otp = binaryCode % (1 << _codeLength);
    return otp.toString().padLeft(_codeLength, '0');
  }

  static bool verifyTOTP(String secret, String code) {
    final timeCounter = (DateTime.now().millisecondsSinceEpoch / 1000 / _timeStepSeconds).floor();
    for (int i = -1; i <= 1; i++) {
      final counter = timeCounter + i;
      final counterBytes = List<int>.generate(8, (j) => (counter >> (8 * (7 - j))) & 0xFF);
      final key = base32Decode(secret);
      final hmacSha1 = Hmac(sha1, key).convert(counterBytes);
      final offset = hmacSha1.bytes[hmacSha1.bytes.length - 1] & 0xF;
      final binaryCode = ((hmacSha1.bytes[offset] & 0x7F) << 24) |
          ((hmacSha1.bytes[offset + 1] & 0xFF) << 16) |
          ((hmacSha1.bytes[offset + 2] & 0xFF) << 8) |
          (hmacSha1.bytes[offset + 3] & 0xFF);
      final otp = binaryCode % (1 << _codeLength);
      if (otp.toString().padLeft(_codeLength, '0') == code) return true;
    }
    return false;
  }

  static String base32Encode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final bytes = utf8.encode(input);
    final buffer = StringBuffer();
    int bits = 0;
    int bitCount = 0;
    for (final byte in bytes) {
      bits = (bits << 8) | byte;
      bitCount += 8;
      while (bitCount >= 5) {
        bitCount -= 5;
        buffer.write(alphabet[(bits >> bitCount) & 0x1F]);
      }
    }
    if (bitCount > 0) {
      buffer.write(alphabet[(bits << (5 - bitCount)) & 0x1F]);
    }
    return buffer.toString();
  }

  static List<int> base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'[^A-Z2-7]'), '');
    final bytes = <int>[];
    int bits = 0;
    int bitCount = 0;
    for (final char in cleaned.split('')) {
      final value = alphabet.indexOf(char);
      if (value == -1) continue;
      bits = (bits << 5) | value;
      bitCount += 5;
      if (bitCount >= 8) {
        bitCount -= 8;
        bytes.add((bits >> bitCount) & 0xFF);
      }
    }
    return bytes;
  }
}
