# Dunya

A Flutter country picker with dial code input, phone validation, and localization support.

| Package | pub.dev | Description |
|---------|---------|-------------|
| [dunya](packages/dunya/) | [![pub](https://img.shields.io/pub/v/dunya.svg)](https://pub.dev/packages/dunya) | Pure Dart core: country data, search, phone validation, localization |
| [dunya_ui](packages/dunya_ui/) | [![pub](https://img.shields.io/pub/v/dunya_ui.svg)](https://pub.dev/packages/dunya_ui) | Flutter widgets: country picker (3 modes), dial code field, flag widget |

> **Most apps should use `dunya_ui`** — it includes everything from `dunya` plus Flutter widgets.

## Quick Start

```yaml
dependencies:
  dunya_ui: ^0.3.0
```

```dart
import 'package:dunya_ui/dunya_ui.dart';

DunyaCountryPicker(
  countries: CountryRepository.all,
  onSelected: (country) => print(country.name),
);
```

## Features

- 250 countries with ISO 3166-1 data (CC0, fully offline)
- 3 picker modes: bottom sheet, dialog, dropdown
- Dial code phone field with per-country validation
- RTL and localization support (Arabic included)
- Favorites, scroll-to-selected, adaptive Cupertino/Material
- Single `DunyaPickerTheme` drives all presentation modes
- Zero state management — pure callbacks

## License

MIT &copy; [Cresentrix](https://github.com/cresentrix)
