/// Localization registry for country names.
///
/// By default, country names are English (from the [Country.name] field).
/// Register additional locales to get translated names:
///
/// ```dart
/// // In your app's initialization:
/// CountryLocalizations.register('ar', kCountryNamesAr);
/// CountryLocalizations.register('es', kCountryNamesEs);
///
/// // Then resolve a name:
/// CountryLocalizations.nameOf('US', 'ar'); // 'الولايات المتحدة'
/// CountryLocalizations.nameOf('US', 'en'); // null (use Country.name)
/// ```
///
/// Each locale map is ~15 KB. Only import the locales you need
/// to keep your app size small.
class CountryLocalizations {
  CountryLocalizations._();

  static final Map<String, Map<String, String>> _locales = {};

  /// Registers a locale with its country name translations.
  ///
  /// [locale] is a language code like `'ar'`, `'es'`, `'fr'`.
  /// [names] is a map of uppercase alpha-2 code to translated name.
  static void register(String locale, Map<String, String> names) {
    _locales[locale.toLowerCase()] = names;
  }

  /// Unregisters a locale to free memory.
  static void unregister(String locale) {
    _locales.remove(locale.toLowerCase());
  }

  /// Returns the translated country name, or `null` if not found.
  ///
  /// Falls back through language subtags: `'ar_EG'` → `'ar'`.
  static String? nameOf(String alpha2, String locale) {
    final code = alpha2.toUpperCase();
    final lang = locale.toLowerCase();

    // Try exact match first (e.g. 'pt_BR')
    final exact = _locales[lang];
    if (exact != null && exact.containsKey(code)) {
      return exact[code];
    }

    // Try base language (e.g. 'pt' from 'pt_BR')
    final base = lang.split(RegExp(r'[_-]')).first;
    if (base != lang) {
      final baseMap = _locales[base];
      if (baseMap != null && baseMap.containsKey(code)) {
        return baseMap[code];
      }
    }

    return null;
  }

  /// Returns all registered locale codes.
  static List<String> get registeredLocales =>
      _locales.keys.toList(growable: false);

  /// Whether a locale is registered.
  static bool isRegistered(String locale) =>
      _locales.containsKey(locale.toLowerCase());

  /// Clears all registered locales.
  static void clearAll() => _locales.clear();
}
