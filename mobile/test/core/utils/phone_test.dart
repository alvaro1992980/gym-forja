import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/utils/phone.dart';

void main() {
  group('[R-40] normalizePhone (same rules as the backend)', () {
    test('[R-40] adds the default country code +591', () {
      expect(normalizePhone('71234567'), '+59171234567');
    });

    test('[R-40] strips spaces, dashes, dots and parentheses', () {
      expect(normalizePhone(' 7123 4567 '), '+59171234567');
      expect(normalizePhone('7123-4567'), '+59171234567');
      expect(normalizePhone('(7) 123.4567'), '+59171234567');
    });

    test('[R-40] keeps an explicit prefix and converts 00 to +', () {
      expect(normalizePhone('+591 7123-4567'), '+59171234567');
      expect(normalizePhone('0059171234567'), '+59171234567');
    });

    test('[R-40] uses the selected country code', () {
      expect(normalizePhone('91234567', countryCode: '+54'), '+5491234567');
      expect(
        normalizePhone('+59171234567', countryCode: '+54'),
        '+59171234567',
      );
    });

    test('[R-40] rejects input that cannot be a phone', () {
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('   '), isNull);
      expect(normalizePhone('abc'), isNull);
      expect(normalizePhone('+12345'), isNull);
      expect(normalizePhone('+5917123456789012'), isNull);
    });
  });
}
