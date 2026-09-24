# dunya

[![pub](https://img.shields.io/pub/v/dunya.svg)](https://pub.dev/packages/dunya)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platforms](https://img.shields.io/badge/platforms-all-green.svg)]()

Pure-Dart country data, search, phone validation, and localization. Powers [dunya_ui](https://pub.dev/packages/dunya_ui).

> **Two packages, one import.** Most apps should use `dunya_ui` (Flutter widgets + this package). Use `dunya` alone for data/logic without Flutter UI.

## Features

- 250 countries with ISO 3166-1 data (CC0, offline)
- Ranked search: alpha2 > dial code > name > native name > alpha3
- Phone validation: per-country min/max digit lengths for every inhabited country and territory
- `PhoneNumber.parse()`: nationalNumber, internationalNumber, e164, dialCode, isValid
- Favorites: pin countries to top in specified order
- Recents: in-memory tracker for recently selected countries
- Localization: 13 built-in locales (AR, DE, ES, FR, HI, IT, JA, KO, PT, RU, TR, UR, ZH)
- Controller with streams, 150ms debounced search, region filtering
- Pure Dart: no Flutter SDK needed, so it also works in servers and CLIs

## Installation

```yaml
dependencies:
  dunya: ^1.1.0
```

## Quick start

```dart
import 'package:dunya/dunya.dart';

// All 250 countries
final countries = CountryRepository.all;

// Lookups
final kuwait = CountryRepository.findByAlpha2('KW');
final usa = CountryRepository.findByAlpha3('USA');
final india = CountryRepository.findByDialCode('+91');

// Shared calling codes return the main country; findAllByDialCode lists all
CountryRepository.findByDialCode('+1');     // United States
CountryRepository.findAllByDialCode('+44'); // GB, GG, IM, JE

// Search
final results = CountrySearch.search(countries, 'united');

// Controller (streams + debounce)
final controller = CountryPickerController();
controller.locale = 'ar'; // enable localized search
print(controller.currentResults.length); // 250, before any search
controller.results.listen((list) => print(list.length)); // emits on changes
controller.search('united');
controller.dispose();
```

## Phone validation

```dart
// Validate
final result = PhoneValidator.validate('50123456', 'KW');
print(result.isValid); // true (Kuwait needs 8 digits)
print(PhoneValidator.maxLengthFor('KW')); // 8

// Parse — get everything in one call
final phone = PhoneNumber.parse('+965', '50 123-456', 'KW');
print(phone.nationalNumber);     // 50123456
print(phone.internationalNumber); // +96550123456
print(phone.e164);               // +96550123456
print(phone.dialCode);           // +965
print(phone.isValid);            // true
```

## Favorites & recents

```dart
// Pin favorites to top
final ordered = CountryFavorites.reorder(countries, ['KW', 'US', 'GB']);
final separatorIndex = CountryFavorites.favoritesCount(ordered, ['KW', 'US', 'GB']);

// Track recent selections
final recents = CountryRecents(maxItems: 5);
recents.add('KW');
recents.add('US');
print(recents.codes); // ['US', 'KW'] — most recent first
```

## Localization

```dart
import 'package:dunya/l10n.dart';

// Register only the locales you need (~8 KB each)
CountryLocalizations.register('ar', kCountryNamesAr);
CountryLocalizations.register('es', kCountryNamesEs);

// Resolve
final name = CountryLocalizations.nameOf('KW', 'ar'); // الكويت

// Or provide your own translations
CountryLocalizations.register('custom', {'KW': 'My Kuwait', 'US': 'My USA'});
```

**Available locales:** `kCountryNamesAr`, `kCountryNamesDe`, `kCountryNamesEs`, `kCountryNamesFr`, `kCountryNamesHi`, `kCountryNamesIt`, `kCountryNamesJa`, `kCountryNamesKo`, `kCountryNamesPt`, `kCountryNamesRu`, `kCountryNamesTr`, `kCountryNamesUr`, `kCountryNamesZh`

## Search ranking

| Score | Match type | Example |
|-------|-----------|---------|
| 0 | Exact alpha2 | `AE` |
| 1 | Exact dial code | `+971` or `971` |
| 2 | Name starts with | `Uni` > United... |
| 3 | Name contains | `land` > Finland |
| 4 | Native name contains | Arabic/localized names |
| 5 | Exact alpha3 | `ARE` |

## Attribution

Country data from [mledoze/countries](https://github.com/mledoze/countries) (CC0)
