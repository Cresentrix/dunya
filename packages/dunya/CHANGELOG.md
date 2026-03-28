# Changelog

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
