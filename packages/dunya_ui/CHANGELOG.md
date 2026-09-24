# Changelog

## [1.1.0] - 2026-09-24

Requires `dunya` 1.1.0, which fixes the dial codes for NANP and `+7` countries and adds the missing phone metadata.

### Upgrading from 1.0.x
No code changes are needed for normal use. Check these if they affect you:
- **Dial codes changed for 32 countries** in `dunya` 1.1.0. See its changelog if you store dial codes.
- **The `codeAndArrow` trigger** no longer shows the country name. Use `DunyaPickerTriggerStyle.all` to keep it.
- **Screen reader labels** no longer end in `", selected"`. Update widget tests that match that text.
- **`DunyaDialCodeField` with `pickerMode: dropdown`** now opens a bottom sheet instead of doing nothing.
- **The A-Z bar** is hidden when country names are shown in a translated language.
- **Autofill** is on by default in the phone field. Pass `autofillHints: null` to turn it off.
- **Subclasses:** `DunyaDialCodeField` is now a `StatefulWidget`, and `DunyaPickerTheme.copyWith` has new parameters. Code that extends either needs updating.

### Fixed
- **`DunyaDialCodeField`:**
  - The `theme` parameter was ignored.
  - `dropdown` mode did nothing. It now opens a bottom sheet.
  - Validation didn't re-run when the country changed.
  - The digit limit counted spaces and dashes, which cut off formatted input.
  - A pasted number with the country's dial code (`+965 5012 3456`, `0096550123456`) kept the code and lost its last digits. The code is now removed.
- **`DunyaDialCodeFormField`:**
  - A number already in the controller counted as empty until edited.
  - Swapping the controller left the listener on the old one.
  - Errors now color the field border.
- **`DunyaCountryPicker`:** the `theme` parameter was ignored. It now also reaches Cupertino dialogs and dropdown overlays. The `codeAndArrow` trigger showed the country name.
- **Country list:**
  - An active search reset when the parent rebuilt.
  - Favorites styling was applied to search results.
  - The A-Z bar jumped into the favorites, landed rows too far down (it ignored separators), overflowed in short lists, and showed English letters next to translated names.
- **Bottom sheets** can now be dragged to resize, as documented.
- **Dropdowns** close when another route is pushed instead of floating above it.
- **Screen readers** hear each country once. The label no longer repeats the flag and name or appends a hardcoded English ", selected".
- **Regional translations** (e.g. `pt_BR`) are used when registered. Before, only the language code was looked up.

### Added
- `DunyaDialCodeField`: `onChanged` (fires with or without validation), `errorText`, `focusNode`, `textInputAction` and `autofillHints`. `DunyaDialCodeFormField` passes these through too.
- `DunyaPickerTheme`: `fieldBorderColor`, `fieldBackgroundColor`, `fieldTextStyle`, `fieldHintStyle`, `fieldHeight` and `errorColor` for the dial code field. The defaults match the previous look.

### Changed
- The README and example use Antarctica and Bouvet Island in the `exclude` example instead of two inhabited countries.

## [1.0.1] - 2026-06-26

### Fixed
- Shortened pubspec description to comply with pub.dev 60-180 character limit
- Updated dunya dependency to ^1.0.1

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
