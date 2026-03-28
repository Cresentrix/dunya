# Changelog

All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [1.0.0] - 2026-03-26

### Added
- **Cupertino adaptive:** 3 Cupertino presentations (bottom sheet, dialog, dropdown) with glass effect
- **Phone validation:** `enableValidation`, `onValidationChanged` on `DunyaDialCodeField`
- **Form integration:** `DunyaDialCodeFormField` with validator, onSaved, autovalidateMode
- **Favorites:** `favorites` param on all pickers and dial code fields
- **Exclude countries:** `exclude` param to hide countries from the list
- **Scroll-to-selected:** auto-scrolls list to currently selected country on open
- **Alphabet sidebar:** A-Z quick navigation bar (adaptive sizing, auto-hides on small lists)
- **Localization:** auto-resolves country names and UI strings from app locale (13 locales)
- **DunyaStrings:** localizable UI strings (headers, buttons, hints) in 13 languages
- **Input filtering:** blocks non-numeric input in phone fields
- **Max length enforcement:** limits input to country's max digit length
- **`onFieldSubmitted`:** callback when user presses done on keyboard
- **`showSelectedIndicator`:** toggle selection highlight and checkmark
- **Better empty state:** styled icon + text when search finds no results
- **RTL support:** `EdgeInsetsDirectional`, `BorderDirectional` throughout
- **Responsive:** dropdown edge detection (opens up/down), dialog min/max constraints, keyboard-aware bottom sheets, text overflow protection

### Fixed
- Cupertino presentations now respect `surfaceColor`, `bottomSheetRadius`, `dialogRadius` from theme
- Parameter ordering lint warnings (14 fixes across 8 files)
- pubspec dependency sorting

### Changed
- Version bump from 0.3.0 to 1.0.0
- `DunyaPickerTheme` properties work consistently across Material and Cupertino

## [0.3.0] - 2026-03-26

### Added
- Cupertino presentations (bottom sheet, dialog, dropdown)
- Adaptive mode with `adaptive` and `glassEffect` params
- Platform-aware shared widgets (CountryListTile, CountrySearchBar)

## [0.1.0] - 2026-03-19

### Added
- DunyaCountryPicker: bottomSheet, dialog, dropdown modes
- DunyaDialCodeField: phone input with flag, dial code, picker
- DunyaPickerTheme: 20+ theme tokens
- 5 trigger styles + custom triggerBuilder
- FlagWidget: 271 SVG flags
- Example app with demo screens
