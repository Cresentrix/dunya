import '../l10n/country_localizations.dart';
import '../models/country.dart';
import '../phone/phone_number.dart';

/// Ranked country search with locale-aware matching.
///
/// Results are sorted by match quality using an internal scoring system:
/// - **0** — exact alpha-2 match (highest priority)
/// - **1** — dial code match
/// - **2** — name prefix match
/// - **3** — name substring match
/// - **4** — native name match
/// - **5** — alpha-3 match (lowest priority)
///
/// Localized names (when [locale] is set) follow the same priority tiers.
/// Arabic/Indic numerals (٠-٩, ۰-۹) are normalized to ASCII for dial code matching.
class CountrySearch {
  /// Searches [all] countries by [query], returning results sorted by
  /// match quality. When [locale] is provided, also matches localized names.
  static List<Country> search(
    List<Country> all,
    String query, {
    String? locale,
  }) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase().trim();
    // Normalize Arabic/Indic digits so ٩١ matches +91
    final normalized = PhoneNumber.stripFormatting(q);
    final scored = all
        .map((c) => MapEntry(c, _score(c, q, normalized, locale)))
        .where((e) => e.value >= 0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return scored.map((e) => e.key).toList(growable: false);
  }

  /// Returns a score from 0 (best) to 5 (weakest match), or -1 for no match.
  static int _score(Country c, String q, String normalized, String? locale) {
    if (c.alpha2.toLowerCase() == q) return 0;
    // Match dial code against both raw query and normalized (Arabic→ASCII)
    if (c.dialCode == q || c.dialCode == '+$q') return 1;
    if (c.dialCode == normalized || c.dialCode == '+$normalized') return 1;
    if (c.name.toLowerCase().startsWith(q)) return 2;
    if (c.name.toLowerCase().contains(q)) return 3;
    if (c.nativeName.toLowerCase().contains(q)) return 4;
    if (c.alpha3.toLowerCase() == q) return 5;
    // Search localized name if a locale is active
    if (locale != null) {
      final localName = CountryLocalizations.nameOf(c.alpha2, locale);
      if (localName != null) {
        if (localName.toLowerCase().startsWith(q)) return 2;
        if (localName.toLowerCase().contains(q)) return 3;
      }
    }
    return -1;
  }
}
