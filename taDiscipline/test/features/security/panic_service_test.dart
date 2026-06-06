import 'package:flutter_test/flutter_test.dart';
import 'package:apex/features/security/services/panic_service.dart';

void main() {
  group('PanicService', () {
    test('constructor ne lance pas', () {
      expect(() => PanicService(), returnsNormally);
    });
  });
}
