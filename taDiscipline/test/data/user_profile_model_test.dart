import 'package:flutter_test/flutter_test.dart';
import 'package:ta_discipline/data/models/user_profile.dart';

void main() {
  group('UserProfile model', () {
    test('toJson / fromJson round-trip', () {
      final profile = UserProfile(
        id: 'u-1',
        email: 'test@example.com',
        hasPin: true,
        hasBiometric: false,
        totpSecret: null,
        createdAt: DateTime(2024, 1, 1),
      );
      final json = profile.toJson();
      final restored = UserProfile.fromJson(json);
      expect(restored.email, 'test@example.com');
      expect(restored.hasPin, isTrue);
      expect(restored.hasBiometric, isFalse);
    });

    test('copyWith modifie hasPin', () {
      final profile = UserProfile(
        id: 'u-1',
        email: 'test@test.com',
        createdAt: DateTime(2024, 1, 1),
      );
      expect(profile.hasPin, false);
      final withPin = profile.copyWith(hasPin: true);
      expect(withPin.hasPin, true);
      expect(withPin.email, profile.email);
    });
  });
}
