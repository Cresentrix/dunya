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

  /// The main country for each calling code shared by several countries,
  /// e.g. `+1` → US rather than American Samoa (first alphabetically).
  static const Map<String, String> _primaryByDialCode = {
    '+1': 'US',
    '+7': 'RU',
    '+39': 'IT',
    '+44': 'GB',
    '+47': 'NO',
    '+61': 'AU',
    '+64': 'NZ',
    '+212': 'MA',
    '+262': 'RE',
    '+358': 'FI',
    '+500': 'FK',
    '+590': 'GP',
    '+599': 'CW',
  };

  /// Finds a country by dial code (e.g. `'+965'` or `'965'`).
  ///
  /// When several countries share a calling code, returns the main one
  /// (`+1` → US, `+44` → GB, `+7` → RU). Use [findAllByDialCode] to get
  /// every country for a code.
  static Country? findByDialCode(String dialCode) {
    final code = _normalizeDialCode(dialCode);
    final primary = _primaryByDialCode[code];
    if (primary != null) return findByAlpha2(primary);
    for (final c in all) {
      if (c.dialCode == code) return c;
    }
    return null;
  }

  /// Returns every country that uses [dialCode] (e.g. `'+1'` or `'1'`),
  /// with the main country first. Empty when no country matches.
  static List<Country> findAllByDialCode(String dialCode) {
    final code = _normalizeDialCode(dialCode);
    final primary = _primaryByDialCode[code];
    final matches = all.where((c) => c.dialCode == code).toList();
    if (primary != null) {
      final index = matches.indexWhere((c) => c.alpha2 == primary);
      if (index > 0) matches.insert(0, matches.removeAt(index));
    }
    return List.unmodifiable(matches);
  }

  static String _normalizeDialCode(String dialCode) {
    final trimmed = dialCode.trim();
    return trimmed.startsWith('+') ? trimmed : '+$trimmed';
  }
}
