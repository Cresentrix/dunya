import 'package:flutter_test/flutter_test.dart';
import 'package:dunya/dunya.dart';

void main() {
  group('CountryRepository data', () {
    test('has 250 countries with unique alpha-2 codes', () {
      final codes = CountryRepository.all.map((c) => c.alpha2).toSet();
      expect(CountryRepository.all.length, 250);
      expect(codes.length, 250);
    });

    test('every dial code is a valid E.164 calling code (1-3 digits)', () {
      final valid = RegExp(r'^\+\d{1,3}$');
      final bad = CountryRepository.all
          .where((c) => c.dialCode.isNotEmpty && !valid.hasMatch(c.dialCode))
          .map((c) => '${c.alpha2}=${c.dialCode}')
          .toList();
      expect(bad, isEmpty);
    });

    test('NANP countries use +1, not an area code', () {
      const nanp = [
        'AG', 'AI', 'AS', 'BB', 'BM', 'BS', 'CA', 'DM', 'DO', 'GD', 'GU', //
        'JM', 'KN', 'KY', 'LC', 'MP', 'MS', 'PR', 'SX', 'TC', 'TT', 'US',
        'VC', 'VG', 'VI',
      ];
      for (final code in nanp) {
        expect(CountryRepository.findByAlpha2(code)!.dialCode, '+1',
            reason: code);
      }
    });

    test('shared calling codes are the bare root', () {
      const expected = {
        'RU': '+7',
        'KZ': '+7',
        'SJ': '+47',
        'AX': '+358',
        'VA': '+39',
        'EH': '+212',
        'UM': '+1',
      };
      expected.forEach((alpha2, dialCode) {
        expect(CountryRepository.findByAlpha2(alpha2)!.dialCode, dialCode,
            reason: alpha2);
      });
    });
  });

  group('CountryRepository.findByDialCode', () {
    test('returns the main country for shared codes', () {
      expect(CountryRepository.findByDialCode('+1')!.alpha2, 'US');
      expect(CountryRepository.findByDialCode('+7')!.alpha2, 'RU');
      expect(CountryRepository.findByDialCode('+44')!.alpha2, 'GB');
      expect(CountryRepository.findByDialCode('+61')!.alpha2, 'AU');
    });

    test('accepts codes without a plus sign', () {
      expect(CountryRepository.findByDialCode('965')!.alpha2, 'KW');
      expect(CountryRepository.findByDialCode('1')!.alpha2, 'US');
    });

    test('returns null for an unknown code', () {
      expect(CountryRepository.findByDialCode('+999'), isNull);
    });
  });

  group('CountryRepository.findAllByDialCode', () {
    test('returns every country for a shared code, main one first', () {
      final result = CountryRepository.findAllByDialCode('+44');
      expect(result.first.alpha2, 'GB');
      expect(
          result.map((c) => c.alpha2), containsAll(['GB', 'GG', 'IM', 'JE']));
      expect(result.length, 4);
    });

    test('returns a single country for a unique code', () {
      final result = CountryRepository.findAllByDialCode('965');
      expect(result.map((c) => c.alpha2), ['KW']);
    });

    test('returns an empty list for an unknown code', () {
      expect(CountryRepository.findAllByDialCode('+999'), isEmpty);
    });
  });
}
