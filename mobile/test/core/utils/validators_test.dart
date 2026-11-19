import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/utils/formatters.dart';
import 'package:gym_app/core/utils/validators.dart';

import '../../helpers/fakes.dart';

void main() {
  final v = Validators(en);

  group('Validators', () {
    test('required', () {
      expect(v.required(null), en.validationRequired);
      expect(v.required('  '), en.validationRequired);
      expect(v.required('x'), isNull);
    });

    test('[R-40] phone', () {
      expect(v.phone(''), en.validationRequired);
      expect(v.phone('123'), en.validationPhoneInvalid);
      expect(v.phone('71234567'), isNull);
    });

    test('[R-42] new password needs 8+ characters and must change', () {
      expect(v.newPassword(''), en.validationRequired);
      expect(v.newPassword('Abc1234'), en.validationPasswordTooShort(8));
      expect(v.newPassword('Abcd1234'), isNull);
      expect(
        v.newPassword('Abcd1234', current: 'Abcd1234'),
        en.validationPasswordSameAsCurrent,
      );
    });

    test('confirmation must match', () {
      expect(v.confirmPassword('a', 'b'), en.validationPasswordsDontMatch);
      expect(v.confirmPassword('Abcd1234', 'Abcd1234'), isNull);
    });
  });

  test('passwordStrength', () {
    expect(passwordStrength('abc'), PasswordStrength.weak);
    expect(passwordStrength('abcdefgh'), PasswordStrength.weak);
    expect(passwordStrength('abcd1234'), PasswordStrength.medium);
    expect(passwordStrength('Abcd1234!x'), PasswordStrength.strong);
  });

  test('formatApiDate shows dd/MM/yyyy without shifting the day', () {
    expect(formatApiDate('2026-12-14'), '14/12/2026');
    expect(formatApiDate('2027-01-01'), '01/01/2027');
  });
}
