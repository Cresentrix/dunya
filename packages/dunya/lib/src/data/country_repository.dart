import '../models/country.dart';
import 'countries_data.dart';

/// Read-only repository of 250 countries bundled from CC0 data.
///
/// All lookups are linear scans over an in-memory list — fast enough for
/// the dataset size and avoids allocating secondary indices.
class CountryRepository {
  /// All bundled countries, sorted alphabetically by English name.
  static final List<Country> all = kCountriesData.toList(growable: false);

  /// Finds a country by ISO 3166-1 alpha-2 code (case-insensitive).
  static Country? findByAlpha2(String alpha2) {
    final code = alpha2.toUpperCase();
    for (final c in all) {
      if (c.alpha2 == code) return c;
    }
    return null;
  }

  /// Finds a country by ISO 3166-1 alpha-3 code (case-insensitive).
  static Country? findByAlpha3(String alpha3) {
    final code = alpha3.toUpperCase();
    for (final c in all) {
      if (c.alpha3 == code) return c;
    }
    return null;
  }

  /// Finds a country by dial code (e.g. `'+965'` or `'965'`).
  /// Returns the first match if multiple countries share a dial code.
  static Country? findByDialCode(String dialCode) {
    final code = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    for (final c in all) {
      if (c.dialCode == code) return c;
    }
    return null;
  }
}
