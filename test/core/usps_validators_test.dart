import 'package:test/test.dart';
import 'package:usps_v3_dart/usps_v3_dart.dart';

void main() {
  group('UspsValidators', () {
    test('isValidZipCode validates 5-digit postal codes', () {
      expect(UspsValidators.isValidZipCode('20260'), isTrue);
      expect(UspsValidators.isValidZipCode(' 90210 '), isTrue);
      expect(UspsValidators.isValidZipCode('2026'), isFalse);
      expect(UspsValidators.isValidZipCode('202600'), isFalse);
      expect(UspsValidators.isValidZipCode('ABCDE'), isFalse);
      expect(UspsValidators.isValidZipCode(null), isFalse);
    });

    test('isValidZipPlus4 validates 4-digit extensions', () {
      expect(UspsValidators.isValidZipPlus4('1234'), isTrue);
      expect(UspsValidators.isValidZipPlus4(' 5678 '), isTrue);
      expect(UspsValidators.isValidZipPlus4('123'), isFalse);
      expect(UspsValidators.isValidZipPlus4('12345'), isFalse);
      expect(UspsValidators.isValidZipPlus4('ABCD'), isFalse);
      expect(UspsValidators.isValidZipPlus4(null), isFalse);
    });

    test('isValidTrackingNumber validates alphanumeric length 10-34', () {
      expect(
        UspsValidators.isValidTrackingNumber('9400111899562537624656'),
        isTrue,
      );
      expect(
        UspsValidators.isValidTrackingNumber('EA123456789US'),
        isTrue,
      );
      expect(UspsValidators.isValidTrackingNumber('12345'), isFalse);
      expect(
        UspsValidators.isValidTrackingNumber('9400 1118 9956 2537 6246 56'),
        isFalse,
      );
      expect(UspsValidators.isValidTrackingNumber(null), isFalse);
    });

    test('requireValidZipCode returns trimmed string on valid input', () {
      expect(UspsValidators.requireValidZipCode(' 78701 '), equals('78701'));
    });

    test('requireValidZipCode throws ArgumentError on invalid input', () {
      expect(
        () => UspsValidators.requireValidZipCode('INVALID'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('requireValidTrackingNumber returns trimmed string on valid input', () {
      expect(
        UspsValidators.requireValidTrackingNumber(' 9400111899562537624656 '),
        equals('9400111899562537624656'),
      );
    });

    test('requireValidTrackingNumber throws ArgumentError on invalid input', () {
      expect(
        () => UspsValidators.requireValidTrackingNumber('SHORT'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
