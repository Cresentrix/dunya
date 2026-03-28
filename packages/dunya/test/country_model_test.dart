import 'package:flutter_test/flutter_test.dart';
import 'package:dunya/dunya.dart';

void main() {
  const country = Country(
    name: 'United Arab Emirates',
    nativeName: 'الإمارات',
    alpha2: 'AE',
    alpha3: 'ARE',
    numeric: 784,
    region: 'Asia',
    subregion: 'Western Asia',
    dialCode: '+971',
    flagCode: 'ae',
  );

  group('Country model', () {
    test('fromJson creates correct instance', () {
      final json = {
        'name': 'United Arab Emirates',
        'nativeName': 'الإمارات',
        'alpha2': 'AE',
        'alpha3': 'ARE',
        'numeric': 784,
        'region': 'Asia',
        'subregion': 'Western Asia',
        'dialCode': '+971',
        'flagCode': 'ae',
      };

      final result = Country.fromJson(json);

      expect(result.name, 'United Arab Emirates');
      expect(result.nativeName, 'الإمارات');
      expect(result.alpha2, 'AE');
      expect(result.alpha3, 'ARE');
      expect(result.numeric, 784);
      expect(result.region, 'Asia');
      expect(result.subregion, 'Western Asia');
      expect(result.dialCode, '+971');
      expect(result.flagCode, 'ae');
    });

    test('toJson returns correct map', () {
      final json = country.toJson();

      expect(json['name'], 'United Arab Emirates');
      expect(json['nativeName'], 'الإمارات');
      expect(json['alpha2'], 'AE');
      expect(json['alpha3'], 'ARE');
      expect(json['numeric'], 784);
      expect(json['region'], 'Asia');
      expect(json['subregion'], 'Western Asia');
      expect(json['dialCode'], '+971');
      expect(json['flagCode'], 'ae');
    });

    test('fromJson and toJson are symmetrical', () {
      final json = country.toJson();
      final restored = Country.fromJson(json);

      expect(restored, country);
    });

    test('copyWith overrides specified fields', () {
      final copy = country.copyWith(
        name: 'UAE',
        dialCode: '+972',
      );

      expect(copy.name, 'UAE');
      expect(copy.dialCode, '+972');
      expect(copy.alpha2, 'AE');
      expect(copy.nativeName, 'الإمارات');
    });

    test('copyWith with no arguments returns equal instance', () {
      final copy = country.copyWith();

      expect(copy, country);
      expect(copy.name, country.name);
      expect(copy.numeric, country.numeric);
    });

    test('equality is based on alpha2', () {
      const other = Country(
        name: 'Different Name',
        nativeName: 'Different',
        alpha2: 'AE',
        alpha3: 'XXX',
        numeric: 0,
        region: '',
        subregion: '',
        dialCode: '',
        flagCode: '',
      );

      expect(country, other);
    });

    test('inequality when alpha2 differs', () {
      const other = Country(
        name: 'United Arab Emirates',
        nativeName: 'الإمارات',
        alpha2: 'US',
        alpha3: 'ARE',
        numeric: 784,
        region: 'Asia',
        subregion: 'Western Asia',
        dialCode: '+971',
        flagCode: 'ae',
      );

      expect(country, isNot(other));
    });

    test('hashCode is based on alpha2', () {
      expect(country.hashCode, 'AE'.hashCode);
    });

    test('hashCode is equal for same alpha2', () {
      const other = Country(
        name: 'Other',
        nativeName: 'Other',
        alpha2: 'AE',
        alpha3: 'OTH',
        numeric: 0,
        region: '',
        subregion: '',
        dialCode: '',
        flagCode: '',
      );

      expect(country.hashCode, other.hashCode);
    });
  });
}
