import 'package:flutter_test/flutter_test.dart';
import 'package:dunya/dunya.dart';

void main() {
  group('Phone metadata coverage', () {
    // Uninhabited, with no subscriber numbers.
    const noNumbering = {'AQ', 'BV', 'HM'};

    test('every inhabited country has phone metadata', () {
      final missing = CountryRepository.all
          .where((c) => !noNumbering.contains(c.alpha2))
          .where((c) => PhoneValidator.metadataFor(c.alpha2) == null)
          .map((c) => c.alpha2)
          .toList();
      expect(missing, isEmpty);
    });

    test('metadata lengths are sane', () {
      for (final c in CountryRepository.all) {
        final meta = PhoneValidator.metadataFor(c.alpha2);
        if (meta == null) continue;
        expect(meta.minLength, greaterThan(0), reason: c.alpha2);
        expect(meta.minLength, lessThanOrEqualTo(meta.maxLength),
            reason: c.alpha2);
        // E.164 caps the whole number at 15 digits.
        final codeDigits = c.dialCode.length - 1;
        expect(codeDigits + meta.maxLength, lessThanOrEqualTo(15),
            reason: c.alpha2);
      }
    });
  });

  group('PhoneValidator', () {
    test('accepts a valid number', () {
      expect(PhoneValidator.validate('50123456', 'KW').isValid, isTrue);
      expect(PhoneValidator.validate('2025551234', 'US').isValid, isTrue);
    });

    test('reports each error reason', () {
      expect(
          PhoneValidator.validate('', 'KW').error, PhoneValidationError.empty);
      expect(PhoneValidator.validate('5012', 'KW').error,
          PhoneValidationError.tooShort);
      expect(PhoneValidator.validate('501234567', 'KW').error,
          PhoneValidationError.tooLong);
      expect(PhoneValidator.validate('5012abcd', 'KW').error,
          PhoneValidationError.invalidCharacters);
      expect(PhoneValidator.validate('50123456', 'ZZ').error,
          PhoneValidationError.unknownCountry);
    });

    test('ignores formatting and normalizes Arabic digits', () {
      expect(PhoneValidator.validate('5012 3456', 'KW').isValid, isTrue);
      expect(PhoneValidator.validate('(202) 555-1234', 'US').isValid, isTrue);
      expect(PhoneValidator.validate('٥٠١٢٣٤٥٦', 'KW').isValid, isTrue);
      expect(PhoneValidator.validate('۵۰۱۲۳۴۵۶', 'KW').isValid, isTrue);
    });

    test('is case-insensitive for the country code', () {
      expect(PhoneValidator.validate('50123456', 'kw').isValid, isTrue);
    });
  });

  group('PhoneNumber.parse', () {
    PhoneNumber parse(String alpha2, String national) {
      final country = CountryRepository.findByAlpha2(alpha2)!;
      return PhoneNumber.parse(country.dialCode, national, alpha2);
    }

    test('builds correct E.164 numbers', () {
      const cases = {
        'KW': ['50123456', '+96550123456'],
        'US': ['2025551234', '+12025551234'],
        'CA': ['4165551234', '+14165551234'],
        'PR': ['7875551234', '+17875551234'],
        'JM': ['8765551234', '+18765551234'],
        'RU': ['9123456789', '+79123456789'],
        'KZ': ['7012345678', '+77012345678'],
        'GB': ['7911123456', '+447911123456'],
        'IN': ['9876543210', '+919876543210'],
        'AE': ['501234567', '+971501234567'],
      };
      cases.forEach((alpha2, value) {
        final phone = parse(alpha2, value[0]);
        expect(phone.e164, value[1], reason: alpha2);
        expect(phone.isValid, isTrue, reason: alpha2);
      });
    });

    test('strips formatting and normalizes Arabic digits', () {
      final phone = parse('KW', '٥٠١ ٢٣-٤٥٦');
      expect(phone.nationalNumber, '50123456');
      expect(phone.e164, '+96550123456');
    });

    test('adds the plus sign when the dial code lacks it', () {
      final phone = PhoneNumber.parse('965', '50123456', 'kw');
      expect(phone.dialCode, '+965');
      expect(phone.alpha2, 'KW');
      expect(phone.e164, '+96550123456');
    });

    test('carries the validation error', () {
      final phone = parse('KW', '5012');
      expect(phone.isValid, isFalse);
      expect(phone.error, PhoneValidationError.tooShort);
    });

    test('a valid number for every country fits in E.164', () {
      for (final c in CountryRepository.all) {
        final meta = PhoneValidator.metadataFor(c.alpha2);
        if (meta == null) continue;
        final phone =
            PhoneNumber.parse(c.dialCode, '9' * meta.minLength, c.alpha2);
        expect(phone.isValid, isTrue, reason: c.alpha2);
        expect(phone.e164, matches(RegExp(r'^\+\d{2,15}$')), reason: c.alpha2);
      }
    });
  });
}
