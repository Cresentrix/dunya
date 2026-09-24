# dunya_ui

[![pub](https://img.shields.io/pub/v/dunya_ui.svg)](https://pub.dev/packages/dunya_ui)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platforms](https://img.shields.io/badge/platforms-all-green.svg)]()

Customizable Flutter country picker. Bottom sheet, dialog, dropdown - one theme drives all modes. Material & Cupertino adaptive, 250 SVG flags, phone validation, 13 locales.

> **One import gets everything.** `dunya_ui` re-exports [dunya](https://pub.dev/packages/dunya) core. Models, search, validation, widgets, flags - all from `import 'package:dunya_ui/dunya_ui.dart'`.

## Features

- 3 picker modes: bottom sheet, dialog, dropdown
- Material 3 + Cupertino adaptive (iOS/macOS auto-detection)
- 250 SVG flags, 100% offline
- Phone validation with `PhoneNumber.parse()` (E.164)
- `DunyaDialCodeFormField` for Flutter `Form` integration
- Favorites, recents, exclude countries
- Scroll-to-selected on open
- A-Z alphabet sidebar for quick navigation
- 13 built-in locales (country names + UI strings)
- 21+ theme tokens via `DunyaPickerTheme`
- 5 trigger styles + fully custom `triggerBuilder`
- RTL support
- Dark/light mode
- Keyboard-aware, responsive, overflow-safe
- Works with BLoC, Riverpod, Provider, setState

## Installation

```yaml
dependencies:
  dunya_ui: ^1.1.0
```

## Quick start

```dart
import 'package:dunya_ui/dunya_ui.dart';

DunyaCountryPicker(
  countries: CountryRepository.all,
  selectedCountry: selected,
  onSelected: (country) => setState(() => selected = country),
)
```

## Picker modes

```dart
// Bottom sheet (default)
DunyaCountryPicker(mode: DunyaPickerMode.bottomSheet, ...)

// Dialog
DunyaCountryPicker(mode: DunyaPickerMode.dialog, ...)

// Dropdown (inline overlay)
DunyaCountryPicker(mode: DunyaPickerMode.dropdown, ...)
```

## Dial code field

```dart
DunyaDialCodeField(
  selectedCountry: selected,
  onCountryChanged: (country) => setState(() => selected = country),
  controller: phoneController,
  onChanged: (text) => print(text),
  enableValidation: true,
  onValidationChanged: (result) => setState(() => _valid = result.isValid),
  errorText: _valid ? null : 'Invalid phone number',
  textInputAction: TextInputAction.next,
)
```

The field supports `bottomSheet` and `dialog` modes. `dropdown` needs a full-width trigger, so the field opens a bottom sheet instead.

Build the E.164 number with `PhoneNumber.parse(country.dialCode, text, country.alpha2).e164`.

## Form integration

```dart
Form(
  key: _formKey,
  child: DunyaDialCodeFormField(
    selectedCountry: _country,
    onCountryChanged: (c) => setState(() => _country = c),
    validator: (phone) {
      if (phone == null || !phone.isValid) return 'Invalid phone';
      return null;
    },
    onSaved: (phone) => _savedPhone = phone!.e164,
    autovalidateMode: AutovalidateMode.onUserInteraction,
  ),
)
```

## Phone number parsing

```dart
final phone = PhoneNumber.parse('+965', '50123456', 'KW');
phone.nationalNumber     // '50123456'
phone.internationalNumber // '+96550123456'
phone.e164               // '+96550123456'
phone.dialCode           // '+965'
phone.isValid            // true
```

## Favorites & exclude

```dart
DunyaCountryPicker(
  countries: CountryRepository.all,
  favorites: const ['KW', 'US', 'GB'], // pinned to top
  exclude: const ['AQ', 'BV'],         // hidden from list
  onSelected: ...,
)
```

## Adaptive (Cupertino)

```dart
DunyaCountryPicker(
  adaptive: true,      // Cupertino on iOS/macOS, Material elsewhere
  glassEffect: true,   // frosted blur on Cupertino presentations
  ...
)
```

## Trigger styles

```dart
DunyaCountryPicker(
  triggerStyle: DunyaPickerTriggerStyle.flagOnly,     // [Flag]
  triggerStyle: DunyaPickerTriggerStyle.codeOnly,     // [+971 v]
  triggerStyle: DunyaPickerTriggerStyle.flagAndCode,  // [Flag +971]
  triggerStyle: DunyaPickerTriggerStyle.codeAndArrow, // [+971 v]
  triggerStyle: DunyaPickerTriggerStyle.all,          // [Flag +971 v] (default)
)

// Fully custom trigger
DunyaCountryPicker(
  triggerBuilder: (context, country, openPicker) {
    return ElevatedButton(
      onPressed: openPicker,
      child: Text(country?.name ?? 'Pick'),
    );
  },
)
```

## Theming

```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      DunyaPickerTheme(
        surfaceColor: Colors.white,
        selectedColor: Color(0xFFF0EFFE),
        selectedIndicatorColor: Color(0xFF7F77DD),
        flagSize: 28,
        flagRadius: BorderRadius.circular(4),
        itemHeight: 56,
        bottomSheetRadius: BorderRadius.vertical(top: Radius.circular(28)),
        dialogRadius: BorderRadius.circular(20),
        dropdownRadius: BorderRadius.circular(12),
        triggerRadius: BorderRadius.circular(12),
        searchBarColor: Color(0xFFF2F2F7),
        searchBarRadius: BorderRadius.circular(12),
        showDividers: true,
        showHandle: true,
        // Dial code field
        fieldBorderColor: Color(0xFFE5E5EA),
        fieldBackgroundColor: Colors.white,
        fieldTextStyle: TextStyle(fontSize: 16),
        fieldHintStyle: TextStyle(color: Color(0xFF8E8E93)),
        fieldHeight: 52,
        errorColor: Color(0xFFD32F2F),
        // Cupertino
        cupertinoSeparatorColor: CupertinoColors.separator,
        cupertinoActionColor: CupertinoColors.systemBlue,
      ),
    ],
  ),
)
```

## Localization

Country names and UI strings auto-resolve from the app's locale:

```dart
import 'package:dunya/l10n.dart';

void main() {
  // Register locales you need (~8 KB each, tree-shaken)
  CountryLocalizations.register('ar', kCountryNamesAr);
  CountryLocalizations.register('es', kCountryNamesEs);
  runApp(MyApp());
}
```

**13 locales:** AR, DE, ES, FR, HI, IT, JA, KO, PT, RU, TR, UR, ZH

UI strings (headers, buttons, hints) also auto-translate via `DunyaStrings`:

```dart
// Auto — reads app locale
DunyaCountryPicker(...)

// Or pass custom strings
DunyaCountryPicker(
  strings: DunyaStrings(selectCountry: 'Pick a country'),
  ...
)
```

## Attribution

Flag icons from [lipis/flag-icons](https://github.com/lipis/flag-icons) (MIT)
Country data from [mledoze/countries](https://github.com/mledoze/countries) (CC0)
