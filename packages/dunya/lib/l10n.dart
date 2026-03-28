/// Localization support for Dunya country names.
///
/// Register only the locales your app needs:
///
/// ```dart
/// import 'package:dunya/l10n.dart';
///
/// void main() {
///   CountryLocalizations.register('ar', kCountryNamesAr);
///   CountryLocalizations.register('es', kCountryNamesEs);
///   runApp(MyApp());
/// }
/// ```
library;

export 'src/l10n/country_localizations.dart';
export 'src/l10n/locales/ar.dart';
export 'src/l10n/locales/de.dart';
export 'src/l10n/locales/es.dart';
export 'src/l10n/locales/fr.dart';
export 'src/l10n/locales/hi.dart';
export 'src/l10n/locales/it.dart';
export 'src/l10n/locales/ja.dart';
export 'src/l10n/locales/ko.dart';
export 'src/l10n/locales/pt.dart';
export 'src/l10n/locales/ru.dart';
export 'src/l10n/locales/tr.dart';
export 'src/l10n/locales/ur.dart';
export 'src/l10n/locales/zh.dart';
