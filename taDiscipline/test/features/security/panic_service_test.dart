import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/features/security/services/panic_service.dart';

void main() {
  group('PanicService', () {
    test('constructor ne lance pas', () {
      expect(() => PanicService(), returnsNormally);
    });
  });
}
