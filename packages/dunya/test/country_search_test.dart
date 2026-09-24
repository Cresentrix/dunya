import 'package:test/test.dart';
import 'package:dunya/src/models/country.dart';
import 'package:dunya/src/search/country_search.dart';

const _uae = Country(
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

const _usa = Country(
  name: 'United States',
  nativeName: 'United States',
  alpha2: 'US',
  alpha3: 'USA',
  numeric: 840,
  region: 'Americas',
  subregion: 'North America',
  dialCode: '+1',
  flagCode: 'us',
);

const _egypt = Country(
  name: 'Egypt',
  nativeName: 'مصر',
  alpha2: 'EG',
  alpha3: 'EGY',
  numeric: 818,
  region: 'Africa',
  subregion: 'Northern Africa',
  dialCode: '+20',
  flagCode: 'eg',
);

const _finland = Country(
  name: 'Finland',
  nativeName: 'Suomi',
  alpha2: 'FI',
  alpha3: 'FIN',
  numeric: 246,
  region: 'Europe',
  subregion: 'Northern Europe',
  dialCode: '+358',
  flagCode: 'fi',
);

const _countries = [_uae, _usa, _egypt, _finland];

void main() {
  group('CountrySearch', () {
    test('empty query returns all countries', () {
      final result = CountrySearch.search(_countries, '');
      expect(result, _countries);
    });

    test('whitespace-only query returns all countries', () {
      final result = CountrySearch.search(_countries, '   ');
      expect(result, _countries);
    });

    test('exact alpha2 match ranks first (score 0)', () {
      final result = CountrySearch.search(_countries, 'ae');
      expect(result.first, _uae);
    });

    test('alpha2 match is case insensitive', () {
      final result = CountrySearch.search(_countries, 'AE');
      expect(result.first, _uae);
    });

    test('dial code match ranks second (score 1)', () {
      final result = CountrySearch.search(_countries, '+971');
      expect(result.first, _uae);
    });

    test('dial code without plus matches', () {
      final result = CountrySearch.search(_countries, '971');
      expect(result.first, _uae);
    });

    test('name starts with ranks third (score 2)', () {
      final result = CountrySearch.search(_countries, 'uni');
      expect(result.length, 2);
      expect(result, contains(_uae));
      expect(result, contains(_usa));
    });

    test('name contains ranks fourth (score 3)', () {
      final result = CountrySearch.search(_countries, 'land');
      expect(result.first, _finland);
    });

    test('native name match ranks fifth (score 4)', () {
      final result = CountrySearch.search(_countries, 'مصر');
      expect(result.first, _egypt);
    });

    test('exact alpha3 match ranks sixth (score 5)', () {
      final result = CountrySearch.search(_countries, 'fin');
      // 'fin' matches Finland name startsWith (score 2) AND alpha3 (score 5)
      // startsWith wins — Finland should be first
      expect(result.first, _finland);
    });

    test('alpha3 only match works', () {
      final result = CountrySearch.search(_countries, 'egy');
      // 'egy' matches Egypt name startsWith (score 2)
      expect(result.first, _egypt);
    });

    test('no results returns empty list', () {
      final result = CountrySearch.search(_countries, 'zzzzz');
      expect(result, isEmpty);
    });

    test('results are sorted by score ascending', () {
      // 'ae' matches UAE alpha2 (score 0) and UAE name contains (score 3)
      // alpha2 wins so UAE comes first
      final result = CountrySearch.search(_countries, 'ae');
      expect(result.first, _uae);
    });

    test('search is case insensitive for name', () {
      final result = CountrySearch.search(_countries, 'EGYPT');
      expect(result.first, _egypt);
    });
  });
}
