# Changelog

## [1.1.0] - 2026-09-24

### Fixed
- **Dial codes:** 32 countries stored the calling code plus an area-code suffix, e.g. US `+1201`, CA `+1204`, RU `+73`, VA `+3906698`. `PhoneNumber.e164` built invalid numbers for them (`+12012025551234`), and searching `+1` found nothing. All 25 NANP countries now use `+1`, RU and KZ use `+7`, and SJ, AX, VA and EH use their real codes. UM had Eswatini's `+268` and now uses `+1`.
- **`findByDialCode`:** returns the main country for shared codes (`+1` → US, `+44` → GB, `+7` → RU) instead of the first one alphabetically, e.g. Guernsey for `+44`.
- **Phone metadata:** added the 50 territories that had none (Puerto Rico, Palestine, Kosovo, Jersey, Guernsey, Isle of Man, Gibraltar, Réunion and more), so their numbers no longer fail with `unknownCountry`.
- **`CountryPickerController`:** the initial list added in the constructor was always dropped by the broadcast stream. `clear()` now cancels a pending debounced search, which used to overwrite the cleared list.
- **Pure Dart:** removed the Flutter SDK constraint and the `flutter_test` dependency, so Dart-only projects can depend on the package.

### Added
- `CountryRepository.findAllByDialCode()` returns every country for a calling code, with the main one first.
- `CountryPickerController.currentResults` returns the latest results, for initial UI state such as `StreamBuilder.initialData`.
- Tests for phone validation, E.164 parsing and data integrity.

## [1.0.1] - 2026-06-26

### Fixed
- Shortened pubspec description to comply with pub.dev 60-180 character limit

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [1.0.0] - 2026-03-26

### Added
- **Phone validation:** `PhoneValidator` with per-country min/max digit lengths (180+ countries)
- **Phone number parsing:** `PhoneNumber.parse()` returns nationalNumber, internationalNumber, e164, dialCode, alpha2, isValid
- **Favorites:** `CountryFavorites.reorder()` pins countries to top in specified order
- **Recents:** `CountryRecents` tracks recently selected countries (in-memory)
- **Localization:** `CountryLocalizations` registry with 13 built-in locales (AR, DE, ES, FR, HI, IT, JA, KO, PT, RU, TR, UR, ZH)
- **Locale-aware search:** `CountrySearch.search()` now accepts optional `locale` parameter
- **Controller locale:** `CountryPickerController.locale` setter for localized search
- **Dial code lookup:** `CountryRepository.findByDialCode()`
- **Phone metadata:** `PhoneMetadata` model, `PhoneValidator.metadataFor()`, `maxLengthFor()`, `minLengthFor()`
- **Strip formatting:** `PhoneNumber.stripFormatting()` public utility

## [0.1.0] - 2026-03-19

### Added
- Country model with ISO 3166-1 data (CC0, mledoze/countries)
- CountryRepository: all 250 countries, findByAlpha2, findByAlpha3
- CountryPickerController: search, select, clear, filterByRegion, streams, 150ms debounce
- CountrySearch: ranked priority search (alpha2 > dial > name > native > alpha3)
