import '../models/country.dart';

/// Tracks recently selected countries (in-memory, resets on app restart).
///
/// Developers can persist this externally (SharedPreferences, Hive, etc.)
/// by reading [codes] and restoring via the constructor.
class CountryRecents {
  final int _maxItems;
  final List<String> _codes = [];

  /// Creates a recents tracker. Optionally restore from [initialCodes].
  CountryRecents({int maxItems = 5, List<String> initialCodes = const []})
      : _maxItems = maxItems {
    for (final code in initialCodes.take(maxItems)) {
      _codes.add(code.toUpperCase());
    }
  }

  /// The current list of recent alpha-2 codes, most recent first.
  List<String> get codes => List.unmodifiable(_codes);

  /// Records a country selection. Moves it to the front if already present.
  void add(String alpha2) {
    final code = alpha2.toUpperCase();
    _codes.remove(code);
    _codes.insert(0, code);
    if (_codes.length > _maxItems) {
      _codes.removeLast();
    }
  }

  /// Clears all recent selections.
  void clear() => _codes.clear();
}

/// Reorders a country list so that favorites appear at the top.
///
/// Favorites are identified by their alpha-2 codes and maintain
/// the order given in [favoriteCodes]. Non-favorite countries
/// keep their original order after the favorites section.
class CountryFavorites {
  /// Splits [countries] into a favorites section (top) followed by
  /// the remaining countries.
  ///
  /// Returns the full reordered list. If [favoriteCodes] is empty,
  /// returns [countries] unchanged.
  static List<Country> reorder(
    List<Country> countries,
    List<String> favoriteCodes,
  ) {
    if (favoriteCodes.isEmpty) return countries;

    final codeSet = favoriteCodes.map((c) => c.toUpperCase()).toSet();
    final favorites = <Country>[];
    final rest = <Country>[];

    // Build favorites in the order specified by favoriteCodes
    final byAlpha2 = <String, Country>{};
    for (final country in countries) {
      if (codeSet.contains(country.alpha2)) {
        byAlpha2[country.alpha2] = country;
      } else {
        rest.add(country);
      }
    }

    for (final code in favoriteCodes) {
      final country = byAlpha2[code.toUpperCase()];
      if (country != null) {
        favorites.add(country);
      }
    }

    return [...favorites, ...rest];
  }

  /// Returns the index where the favorites section ends.
  ///
  /// Returns 0 if [favoriteCodes] is empty. Useful for rendering
  /// a separator between favorites and the rest.
  static int favoritesCount(
    List<Country> countries,
    List<String> favoriteCodes,
  ) {
    if (favoriteCodes.isEmpty) return 0;
    final codeSet = favoriteCodes.map((c) => c.toUpperCase()).toSet();
    return countries.where((c) => codeSet.contains(c.alpha2)).length;
  }
}
