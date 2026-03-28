# DUNYA — دنيا
> Flutter country picker · Two packages · Phase 1: iOS + Android

---

## 1. OVERVIEW

**Name:** Dunya (دنيا = "the world" in Arabic)
**Packages:** `dunya` (pure Dart core) + `dunya_ui` (Flutter widgets)
**License:** MIT · Country data: CC0 · Flag SVGs: MIT (attribution required)
**Version start:** 0.1.0

| Package | Role | Flutter dep |
|---|---|---|
| `dunya` | Country model, search, controller | No |
| `dunya_ui` | Stateless widgets, 3 presentation modes, theme | Yes |

**Core rules:**
- Zero state management inside — pure callbacks only
- Single `DunyaPickerTheme` drives all 3 presentation modes
- 100% offline — no network calls ever
- All data CC0 or MIT — safe to bundle forever

---

## 2. PROBLEM & SOLUTION

**Problem:** Multi-project teams end up with widgets that look different from each other because each has independent style props — no shared token contract.

```dart
// Before — 3 APIs = 3 different looks
PhoneField(flagSize: 20, borderRadius: 8)
CountryPicker(itemHeight: 48, radius: 12)
InlinePicker(flagWidth: 32, cornerRadius: 16)

// With Dunya — 1 theme = identical look everywhere
DunyaPickerTheme(flagSize: 28, itemHeight: 56)
// DunyaDialCodeField + DunyaCountryPicker(.bottomSheet/.dialog/.dropdown)
// ALL read from the same DunyaPickerTheme
```

---

## 3. DATA SOURCES

| Source | Use | License | Attribution |
|---|---|---|---|
| `mledoze/countries` | 250 countries, names, codes, regions — bundled as Dart const | CC0 | Not required |
| `lipis/flag-icons` | SVG flag files named by ISO alpha-2 — bundled as assets | MIT | Required in LICENSE + README |

**Never use:** restcountries.com (private API), flagcdn.com (CDN/runtime), any runtime fetch.

---

## 4. FOLDER STRUCTURE

```
dunya/                                     ← monorepo root
├── packages/
│   ├── dunya/                             ← pure Dart core
│   │   ├── lib/
│   │   │   ├── dunya.dart                 ← public barrel
│   │   │   └── src/
│   │   │       ├── models/country.dart
│   │   │       ├── data/countries_data.dart   ← generated CC0
│   │   │       ├── controller/country_picker_controller.dart
│   │   │       └── search/country_search.dart
│   │   ├── test/
│   │   ├── pubspec.yaml
│   │   ├── analysis_options.yaml
│   │   ├── README.md
│   │   ├── CHANGELOG.md
│   │   └── LICENSE
│   │
│   └── dunya_ui/                          ← Flutter UI
│       ├── lib/
│       │   ├── dunya_ui.dart              ← public barrel
│       │   └── src/
│       │       ├── theme/dunya_picker_theme.dart
│       │       ├── widgets/
│       │       │   ├── dunya_country_picker.dart
│       │       │   ├── presentations/
│       │       │   │   ├── bottom_sheet_presentation.dart
│       │       │   │   ├── dialog_presentation.dart
│       │       │   │   └── dropdown_presentation.dart
│       │       │   ├── shared/
│       │       │   │   ├── country_list_view.dart
│       │       │   │   ├── country_list_tile.dart
│       │       │   │   ├── flag_widget.dart
│       │       │   │   └── country_search_bar.dart
│       │       │   └── dial_code_field.dart
│       │       └── utils/flag_resolver.dart
│       ├── assets/flags/                  ← 250 SVGs (lipis/flag-icons MIT)
│       ├── test/
│       ├── example/                     ← device test app + pub.dev example
│       │   ├── lib/main.dart
│       │   └── pubspec.yaml
│       ├── pubspec.yaml
│       ├── analysis_options.yaml
│       ├── README.md
│       ├── CHANGELOG.md
│       └── LICENSE
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── publish.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
├── CONTRIBUTING.md
├── DUNYA.md                               ← this file
└── melos.yaml
```

---

## 5. ARCHITECTURE

```
Developer App (BLoC / Riverpod / Provider / setState / GetX — anything)
        │  passes List<Country> + onSelected callback
        ▼
┌──────────────────────────────────────────────────────┐
│  dunya_ui  (Flutter)                                 │
│  DunyaCountryPicker → routes by DunyaPickerMode      │
│  ├── BottomSheetPresentation                         │
│  ├── DialogPresentation       ← all share same       │
│  └── DropdownPresentation        inner widgets       │
│       └── CountryListView                            │
│            ├── CountrySearchBar                      │
│            └── CountryListTile + FlagWidget          │
│  DunyaDialCodeField                                  │
│  DunyaPickerTheme (ThemeExtension)                   │
└──────────────┬───────────────────────────────────────┘
               │ depends on
               ▼
┌──────────────────────────────────────────────────────┐
│  dunya  (pure Dart — zero Flutter UI import)         │
│  CountryPickerController                             │
│  CountryRepository  ← CC0 bundled data              │
│  CountrySearch      ← ranked search                 │
│  Country model                                       │
└──────────────────────────────────────────────────────┘
```

---

## 6. COUNTRY MODEL

```dart
// packages/dunya/lib/src/models/country.dart

class Country {
  final String name;        // "United Arab Emirates"
  final String nativeName;  // "دولة الإمارات العربية المتحدة"
  final String alpha2;      // "AE"
  final String alpha3;      // "ARE"
  final int    numeric;     // 784
  final String region;      // "Asia"
  final String subregion;   // "Western Asia"
  final String dialCode;    // "+971"
  final String flagCode;    // "ae"

  const Country({
    required this.name,
    required this.nativeName,
    required this.alpha2,
    required this.alpha3,
    required this.numeric,
    required this.region,
    required this.subregion,
    required this.dialCode,
    required this.flagCode,
  });

  Country copyWith({...});
  factory Country.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) =>
      other is Country && alpha2 == other.alpha2;

  @override
  int get hashCode => alpha2.hashCode;
}
```

---

## 7. CORE PACKAGE — dunya

### CountryPickerController

```dart
class CountryPickerController {
  Stream<List<Country>> get results  => _resultsController.stream;
  Stream<Country?>      get selected => _selectedController.stream;
  List<Country> get allCountries     => CountryRepository.all;
  Country?      get currentSelection => _selected;

  void search(String query);        // debounced 150ms
  void select(Country country);
  void clear();
  void filterByRegion(String? region); // null = all
  void dispose();
}
```

### CountryRepository

```dart
class CountryRepository {
  static final List<Country> all =
      _kCountriesRaw.map(Country.fromJson).toList(growable: false);

  static Country? findByAlpha2(String alpha2);
  static Country? findByAlpha3(String alpha3);
}
// _kCountriesRaw generated from mledoze/countries (CC0)
```

### Barrel

```dart
// packages/dunya/lib/dunya.dart
export 'src/models/country.dart';
export 'src/controller/country_picker_controller.dart';
export 'src/data/country_repository.dart';
// country_search.dart is internal — not exported
```

---

## 8. SEARCH ALGORITHM

```dart
// packages/dunya/lib/src/search/country_search.dart
// Score 0 → exact alpha2     ("AE")
// Score 1 → exact dial code  ("+971" or "971")
// Score 2 → name starts with ("Uni" → United...)
// Score 3 → name contains    ("land" → Finland)
// Score 4 → native name      ("مصر" → Egypt)
// Score 5 → exact alpha3     ("ARE")
// Score -1 → excluded

class CountrySearch {
  static List<Country> search(List<Country> all, String query) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase().trim();
    final scored = all
        .map((c) => MapEntry(c, _score(c, q)))
        .where((e) => e.value >= 0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return scored.map((e) => e.key).toList(growable: false);
  }

  static int _score(Country c, String q) {
    if (c.alpha2.toLowerCase() == q)             return 0;
    if (c.dialCode == q || c.dialCode == '+$q')  return 1;
    if (c.name.toLowerCase().startsWith(q))      return 2;
    if (c.name.toLowerCase().contains(q))        return 3;
    if (c.nativeName.toLowerCase().contains(q))  return 4;
    if (c.alpha3.toLowerCase() == q)             return 5;
    return -1;
  }
}
```

---

## 9. UI PACKAGE — dunya_ui

### DunyaCountryPicker

```dart
enum DunyaPickerMode { bottomSheet, dialog, dropdown }

/// Controls which elements appear in the trigger / dial code area.
enum DunyaPickerTriggerStyle {
  flagOnly,       // [🇦🇪]
  codeOnly,       // [+971]
  flagAndCode,    // [🇦🇪 +971]
  codeAndArrow,   // [+971 ˅]
  all,            // [🇦🇪 +971 ˅]  ← default
}

class DunyaCountryPicker extends StatelessWidget {
  final List<Country>            countries;
  final Country?                 selectedCountry;
  final ValueChanged<Country>    onSelected;
  final DunyaPickerMode          mode;           // default: bottomSheet
  final DunyaPickerTheme?        theme;
  final String?                  searchHint;
  final Widget Function(BuildContext, Country)? itemBuilder;
  final WidgetBuilder?           emptyBuilder;

  // Trigger customization
  final DunyaPickerTriggerStyle  triggerStyle;   // default: all
  final Widget Function(BuildContext, Country?, VoidCallback)? triggerBuilder;
  final bool                     selectionLabel; // default: true — shows
      // label below field confirming selected country name + flag + dial code

  // Routes internally to _BottomSheetPresentation / _DialogPresentation
  // / _DropdownPresentation — all wrap the same _CountryListView
}
```

### DunyaDialCodeField

```dart
// Renders: [ Flag | +971 ˅ ] | [ number input ]
// Flag+code section taps to open DunyaCountryPicker with chosen mode
// Uses same FlagWidget + DunyaPickerTheme as standalone picker

class DunyaDialCodeField extends StatelessWidget {
  final Country?               selectedCountry;
  final ValueChanged<Country>  onCountryChanged;
  final TextEditingController? controller;
  final DunyaPickerMode        pickerMode;       // default: bottomSheet
  final DunyaPickerTheme?      theme;
  final String?                numberHint;

  // Trigger customization
  final DunyaPickerTriggerStyle  triggerStyle;   // default: all
  final Widget Function(BuildContext, Country?, VoidCallback)? triggerBuilder;
  final bool                     selectionLabel; // default: true
}
```

### DialCodeField Anatomy

```
┌─────────────────────────────────────────────────┐  ← radius 12
│ [Flag 24px] [+971] [˅]  │  [50 123 4567 hint]  │
│ ←── tap area 44dp min ──│← flex input ─────────│
│ ←── 12dp pad ──────────→│← 12dp pad ──────────→│
└─────────────────────────────────────────────────┘
  ↑ vertical divider: 1dp, borderColor token
  ↑ flag size: 24dp width (smaller than list — field context)
  ↑ dial code text: 13dp, fontWeight 600
```

### FlagWidget

```dart
class FlagWidget extends StatelessWidget {
  final String         alpha2;
  final double?        size;    // width; height = size * 0.67
  final BorderRadius?  radius;

  // SvgPicture.asset from packages/dunya_ui/assets/flags/{alpha2}.svg
  // Fallback: grey rounded rect placeholder
  // Semantics: '${alpha2} flag', excludeSemantics: true
}
```

### Trigger Styles & Custom Trigger Builder

```dart
// Built-in trigger styles
DunyaCountryPicker(
  triggerStyle: DunyaPickerTriggerStyle.flagOnly,    // [🇦🇪]
  triggerStyle: DunyaPickerTriggerStyle.codeOnly,    // [+971]
  triggerStyle: DunyaPickerTriggerStyle.flagAndCode,  // [🇦🇪 +971]
  triggerStyle: DunyaPickerTriggerStyle.codeAndArrow, // [+971 ˅]
  triggerStyle: DunyaPickerTriggerStyle.all,          // [🇦🇪 +971 ˅] default
)

// Fully custom trigger — overrides triggerStyle completely
DunyaCountryPicker(
  countries: CountryRepository.all,
  onSelected: (c) => setState(() => _selected = c),
  selectedCountry: _selected,
  triggerBuilder: (context, country, openPicker) {
    return ElevatedButton.icon(
      onPressed: openPicker,
      icon: country != null
          ? FlagWidget(alpha2: country.alpha2, size: 20)
          : const Icon(Icons.public),
      label: Text(country?.name ?? 'Choose country'),
    );
  },
)

// Selection label — shown below the trigger when a country is selected
// Displays: [🇦🇪] United Arab Emirates  +971
// Set selectionLabel: false to hide it
DunyaCountryPicker(
  selectionLabel: true,  // default
  ...
)

// triggerBuilder on DunyaDialCodeField
DunyaDialCodeField(
  selectedCountry: _selected,
  onCountryChanged: (c) => setState(() => _selected = c),
  triggerBuilder: (context, country, openPicker) {
    return GestureDetector(
      onTap: openPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (country != null) FlagWidget(alpha2: country.alpha2, size: 20),
            const SizedBox(width: 4),
            Text(country?.dialCode ?? '+--'),
          ],
        ),
      ),
    );
  },
)
```

### Flag Resolver

```dart
// packages/dunya_ui/lib/src/utils/flag_resolver.dart
class FlagResolver {
  static String assetPath(String alpha2) =>
      'packages/dunya_ui/assets/flags/${alpha2.toLowerCase()}.svg';
}
```

### Barrel

```dart
// packages/dunya_ui/lib/dunya_ui.dart
export 'package:dunya/dunya.dart';
export 'src/theme/dunya_picker_theme.dart';
export 'src/widgets/dunya_country_picker.dart';
export 'src/widgets/dial_code_field.dart';
export 'src/widgets/shared/flag_widget.dart';
export 'src/widgets/shared/country_list_tile.dart';
export 'src/widgets/shared/country_search_bar.dart';
// presentations/ are internal — not exported
```

---

## 10. THEME SYSTEM

### DunyaPickerTheme

```dart
class DunyaPickerTheme extends ThemeExtension<DunyaPickerTheme> {
  // Container
  final Color?        surfaceColor;
  final Color?        barrierColor;

  // Per-mode radius
  final BorderRadius? bottomSheetRadius; // default: top 28, bottom 0
  final BorderRadius? dialogRadius;      // default: all 20
  final BorderRadius? dropdownRadius;    // default: all 12
  final BorderRadius? triggerRadius;     // default: all 12 (field + dial)

  // List items
  final Color?        selectedColor;
  final Color?        selectedIndicatorColor;
  final double?       itemHeight;        // default: 56
  final bool?         showDividers;      // default: true

  // Flag
  final double?       flagSize;          // default: 28 (list), 24 (dial field)
  final BorderRadius? flagRadius;        // default: all 4

  // Typography
  final TextStyle?    countryNameStyle;
  final TextStyle?    codeStyle;
  final TextStyle?    searchHintStyle;

  // Search bar
  final Color?        searchBarColor;
  final BorderRadius? searchBarRadius;   // default: all 12

  // Bottom sheet handle
  final Color?        handleColor;
  final bool?         showHandle;        // default: true

  static DunyaPickerTheme of(BuildContext context) =>
      Theme.of(context).extension<DunyaPickerTheme>() ?? const DunyaPickerTheme();

  @override DunyaPickerTheme copyWith({...});
  @override DunyaPickerTheme lerp(ThemeExtension? other, double t);
}
```

### App Setup

```dart
// Minimal
MaterialApp(
  theme: ThemeData(
    extensions: [const DunyaPickerTheme()],
  ),
)

// Custom
MaterialApp(
  theme: ThemeData(
    extensions: [
      DunyaPickerTheme(
        selectedColor:          const Color(0xFFF0EFFE),
        selectedIndicatorColor: const Color(0xFF7F77DD),
        flagSize:               28,
        flagRadius:             BorderRadius.circular(4),
        bottomSheetRadius:      const BorderRadius.vertical(top: Radius.circular(28)),
        dialogRadius:           BorderRadius.circular(20),
        dropdownRadius:         BorderRadius.circular(12),
        itemHeight:             56,
      ),
    ],
  ),
)
```

---

## 11. PRESENTATION MODES

### Mode Specs

| Property | Bottom Sheet | Dialog | Dropdown |
|---|---|---|---|
| Container radius | top: 28, bottom: 0 | all: 20 | all: 12 |
| Barrier | dark overlay | dark overlay | none |
| Dismiss | drag or tap barrier | tap barrier / Cancel btn | tap outside |
| Handle | yes 36×4dp | no | no |
| Close button | top-right × | top-right × | no |
| Cancel/Confirm | no | yes | no |
| Max height | 75% screen | 80% screen | 320dp |

### Bottom Sheet Anatomy

```
┌──────────────────────────────┐  ← r=28 top
│   ━━━━━━  (36×4dp handle)   │
│                              │
│  Select Country       [×]    │
│  ┌────────────────────────┐  │
│  │ 🔍  Search...          │  │  ← r=12
│  └────────────────────────┘  │
│  ─────────────────────────── │  ← 1dp divider
│  [Flag] Country Name    AE ✓ │  ← item h=56dp
│  [Flag] Country Name    US   │
│  ...                         │
└──────────────────────────────┘  ← r=0 bottom (flush)
```

---

## 12. TOKENS

### Radius & Spacing

| Token | Default | Notes |
|---|---|---|
| `bottomSheetRadius` | top: 28, bottom: 0 | Material 3 spec |
| `dialogRadius` | all: 20 | Material 3 spec |
| `dropdownRadius` | all: 12 | Inline overlay |
| `triggerRadius` | all: 12 | Field + dial code field |
| `searchBarRadius` | all: 12 | |
| `flagRadius` | all: 4 | Not pill |
| `itemHeight` | 56dp | WCAG minimum |
| `flagSize` | 28dp (list) / 24dp (dial) | Height = w × 0.67 |
| `searchBarHeight` | 44dp | Fixed, accessibility |
| `minTapTarget` | 44×44dp | WCAG, not overridable |
| `searchDebounce` | 150ms | Not overridable |
| `horizontalPadding` | 14dp | Not overridable |
| `handleWidth` | 36dp | Bottom sheet only |
| `handleHeight` | 4dp | Bottom sheet only |

### Dark / Light Colors

| Token | Light | Dark |
|---|---|---|
| `surfaceColor` | `#ffffff` | `#1c1c1e` |
| `barrierColor` | `rgba(0,0,0,0.35)` | `rgba(0,0,0,0.65)` |
| `selectedColor` | `#f0effe` | `#2a2a3a` |
| `selectedIndicatorColor` | `#7F77DD` | `#a89ff0` |
| `searchBarColor` | `#f2f2f7` | `#2c2c2e` |
| `handleColor` | `#d1d1d6` | `#48484a` |
| `dividerColor` | `#f0eff9` | `#2c2c2e` |
| `borderColor` | `#e5e5ea` | `#2c2c2e` |
| Country name text | `#1c1c1e` | `#ebebf5` |
| Secondary text | `#8e8e93` | `#8e8e93` |

---

## 13. PUBSPEC FILES

### packages/dunya/pubspec.yaml

```yaml
name: dunya
description: >
  Pure-Dart country picker core. State-management-agnostic,
  offline-first, ISO 3166-1 data (CC0). Powers dunya_ui.
version: 0.1.0
homepage: https://github.com/yourname/dunya
repository: https://github.com/yourname/dunya
issue_tracker: https://github.com/yourname/dunya/issues
topics: [country, picker, iso-3166, internationalization, flutter]
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"
platforms:
  android:
  ios:
dependencies:
  flutter:
    sdk: flutter
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

### packages/dunya_ui/pubspec.yaml

```yaml
name: dunya_ui
description: >
  Customizable Flutter country picker. Bottom sheet, dialog, dropdown
  — one DunyaPickerTheme drives all modes. Material 3, dark/light,
  works with all state management solutions.
version: 0.1.0
homepage: https://github.com/yourname/dunya
repository: https://github.com/yourname/dunya
issue_tracker: https://github.com/yourname/dunya/issues
topics: [country, picker, flag, material, flutter]
environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.10.0"
platforms:
  android:
  ios:
dependencies:
  flutter:
    sdk: flutter
  dunya: ^0.1.0
  flutter_svg: ^2.0.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
flutter:
  assets:
    - packages/dunya_ui/assets/flags/
```

---

## 14. ANALYSIS_OPTIONS.YAML

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  strong-mode:
    implicit-casts: false
    implicit-dynamic: false
  errors:
    missing_required_param: error
    missing_return: error
    dead_code: warning

linter:
  rules:
    - always_declare_return_types
    - always_put_required_named_parameters_first
    - avoid_dynamic_calls
    - avoid_print
    - avoid_relative_lib_imports
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_single_quotes
    - sort_pub_dependencies
    - unawaited_futures
```

---

## 15. CI / CD

### .github/workflows/ci.yml

```yaml
name: CI
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: stable
      - run: cd packages/dunya && flutter pub get
      - run: cd packages/dunya_ui && flutter pub get
      - run: dart format --set-exit-if-changed packages/dunya/lib
      - run: dart format --set-exit-if-changed packages/dunya_ui/lib
      - run: cd packages/dunya && dart analyze --fatal-infos
      - run: cd packages/dunya_ui && dart analyze --fatal-infos
      - run: cd packages/dunya && flutter test
      - run: cd packages/dunya_ui && flutter test
      - run: cd packages/dunya && dart pub publish --dry-run
      - run: cd packages/dunya_ui && dart pub publish --dry-run
```

### .github/workflows/publish.yml

```yaml
name: Publish
on:
  push:
    tags: ['v*.*.*']
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: stable
      - run: cd packages/dunya && dart pub publish --force
      - run: cd packages/dunya_ui && dart pub publish --force
```

---

## 16. PUB.DEV SCORE CHECKLIST

Target: **160 / 160 points**

| Points | Requirement |
|---|---|
| 30 | `dart format` clean + `flutter_lints` zero warnings |
| 30 | 100% public API `///` dartdoc comments |
| 20 | `platforms: android + ios` declared in pubspec |
| 20 | `dart analyze --fatal-infos` passes |
| 20 | Broad `^x.y.z` constraints, no pinned deps |
| 20 | Sound null safety, Dart 3.x |
| 20 | `CHANGELOG.md` in Keep a Changelog format |

**Before every publish:**
```bash
dart format .
dart analyze --fatal-infos
flutter test
dart pub publish --dry-run
```

---

## 17. TEST STRATEGY

### dunya — unit tests

```
test/
  country_model_test.dart    → fromJson, toJson, copyWith, equality, hashCode
  country_search_test.dart   → empty query, alpha2, dialCode, native name, no results, case
  controller_test.dart       → debounce 150ms, select, clear, filterByRegion, stream, dispose
```

### dunya_ui — widget tests

```
test/
  flag_widget_test.dart           → SVG renders, unknown code fallback, size, semantics
  country_list_tile_test.dart     → flag+name shown, onTap fires, selected state, theme color
  dunya_country_picker_test.dart  → all 3 modes open/close, onSelected fires, search filters,
                                    emptyBuilder shown, theme applied
  dial_code_field_test.dart       → flag shown, tap opens picker, onCountryChanged fires
```

### Golden tests

```
test/goldens/
  list_tile_light.png
  list_tile_dark.png
  list_tile_selected.png
  flag_widget.png
  bottom_sheet_light.png
  bottom_sheet_dark.png
  dialog_light.png
  dropdown_light.png
```

---

## 18. ACCESSIBILITY

| Requirement | Implementation |
|---|---|
| Semantics | `CountryListTile`: label = `"${name}, code ${alpha2}"` · `FlagWidget`: label = `"${name} flag"`, excludeSemantics: true |
| Tap targets | `itemHeight` 56dp min · all interactive elements 44×44dp min |
| Color contrast | WCAG AA — 4.5:1 text on surface with default tokens |
| Screen readers | VoiceOver + TalkBack · announces name + position e.g. "United Arab Emirates, 1 of 250" |
| Focus order | Search bar auto-focused on open · logical tab order throughout |
| Motion | Opacity transitions only — safe for `prefers-reduced-motion` |

---

## 19. FILE TEMPLATES

### LICENSE

```
MIT License

Copyright (c) 2026 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

---

Flag icons (assets/flags/) by lipis/flag-icons
https://github.com/lipis/flag-icons
MIT License · Copyright (c) 2013 Panayiotis Lipiridis

Country data bundled from mledoze/countries
https://github.com/mledoze/countries
CC0 1.0 Universal Public Domain Dedication
```

### CHANGELOG.md

```markdown
# Changelog
All notable changes documented here.
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [Unreleased]

## [0.1.0] - 2026-xx-xx
### Added
- Country model with ISO 3166-1 data (CC0, mledoze/countries)
- CountryPickerController — search, select, filter, streams
- CountrySearch — priority ranked, diacritic-aware
- All 250 countries bundled offline
- DunyaCountryPicker — bottomSheet, dialog, dropdown modes
- DunyaPickerTheme — single ThemeExtension for all modes
- FlagWidget — SVG assets from lipis/flag-icons (MIT)
- DunyaDialCodeField
- Dark and light mode
- iOS and Android support
```

### CONTRIBUTING.md

```markdown
# Contributing to Dunya

## Branch naming
- feature/short-description
- fix/short-description
- chore/short-description

## Before submitting a PR
1. `dart format .`
2. `dart analyze --fatal-infos`
3. `flutter test`
4. Update `CHANGELOG.md` under `[Unreleased]`
5. Add `///` dartdoc to any new public API

## Commit style
`type: short description` — types: feat, fix, chore, docs, test

## Reporting bugs
Use the bug report issue template.
```

### .github/ISSUE_TEMPLATE/bug_report.md

```markdown
---
name: Bug report
about: Something is broken
---

**Package:** dunya / dunya_ui (delete one)
**Version:**
**Flutter version:**
**Platform:** iOS / Android

**What happened:**

**Expected behavior:**

**Minimal reproduction:**
```dart
// paste code here
```

**Screenshots (if applicable):**
```

### .github/ISSUE_TEMPLATE/feature_request.md

```markdown
---
name: Feature request
about: Suggest a new feature
---

**Is this for dunya (core) or dunya_ui (widgets)?**

**What problem does this solve?**

**Proposed solution:**

**Phase:** 1 / 2 / 3
```

### .github/pull_request_template.md

```markdown
## What does this PR do?

## Checklist
- [ ] `dart format .` run
- [ ] `dart analyze --fatal-infos` passes
- [ ] Tests added / updated
- [ ] CHANGELOG.md updated
- [ ] Public API has `///` dartdoc comments
- [ ] `dart pub publish --dry-run` passes
```

### melos.yaml

```yaml
name: dunya
packages:
  - packages/*
scripts:
  analyze:
    run: melos exec -- dart analyze --fatal-infos
  format:
    run: melos exec -- dart format --set-exit-if-changed .
  test:
    run: melos exec -- flutter test
  publish:dry:
    run: melos exec -- dart pub publish --dry-run
```

### Example App

> Lives at `packages/dunya_ui/example/` — NOT a separate `sample_app` folder.
> Serves as both the device test app (run on iOS/Android) and the pub.dev example tab.

### example/lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

void main() => runApp(const DunyaExample());

class DunyaExample extends StatefulWidget {
  const DunyaExample({super.key});
  @override
  State<DunyaExample> createState() => _DunyaExampleState();
}

class _DunyaExampleState extends State<DunyaExample> {
  Country? _selected;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        extensions: [const DunyaPickerTheme()],
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Dunya Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Bottom sheet
              DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _selected,
                onSelected: (c) => setState(() => _selected = c),
              ),
              const SizedBox(height: 16),
              // Dial code field
              DunyaDialCodeField(
                selectedCountry: _selected,
                onCountryChanged: (c) => setState(() => _selected = c),
                numberHint: '50 123 4567',
              ),
              if (_selected != null) ...[
                const SizedBox(height: 24),
                Text('Selected: ${_selected!.name} (${_selected!.alpha2})'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

### README.md (both packages — adjust per package)

```markdown
# dunya / dunya_ui

[![pub](https://img.shields.io/pub/v/dunya.svg)](https://pub.dev/packages/dunya)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20Android-green.svg)]()

<!-- Screenshot GIF here -->

## Features
- 250 countries · ISO 3166-1 · offline
- Bottom sheet, dialog, dropdown — one theme for all
- Works with BLoC, Riverpod, Provider, setState, any state manager
- Material 3 · dark/light mode · SVG flags
- Accessible · WCAG AA

## Installation
```yaml
dependencies:
  dunya_ui: ^0.1.0
```

## Quick start
```dart
DunyaCountryPicker(
  countries: CountryRepository.all,
  selectedCountry: selected,
  onSelected: (country) => setState(() => selected = country),
)
```

## Theming
```dart
MaterialApp(
  theme: ThemeData(
    extensions: [
      DunyaPickerTheme(selectedColor: Color(0xFFF0EFFE)),
    ],
  ),
)
```

## Attribution
Flag icons from [lipis/flag-icons](https://github.com/lipis/flag-icons) · MIT License
Country data from [mledoze/countries](https://github.com/mledoze/countries) · CC0
```

---

## 20. NON-FUNCTIONAL REQUIREMENTS

| Category | Requirement |
|---|---|
| Performance | Search results in < 16ms for 250 countries on low-end device |
| Bundle size | `dunya` < 500KB · `dunya_ui` < 2MB including all SVG flags |
| Compatibility | Flutter ≥ 3.10 · Dart ≥ 3.0 · iOS ≥ 12 · Android API ≥ 21 |
| Pub points | 160 / 160 |
| Offline | 100% — zero network calls at runtime |
| Null safety | Sound null safety · Dart 3.x · no `dynamic` |

---

## 21. PHASE ROADMAP

| Phase | Version | Scope |
|---|---|---|
| Phase 1 | 0.1.0 | `dunya` + `dunya_ui` · Material · iOS + Android · 3 modes · single theme |
| Phase 2 | 0.3.0 | Cupertino widgets · adaptive mode · Web + macOS + Windows + Linux |
| Phase 3 | 1.0.0 | Multi-select · dial code formatter · favorites/recents · swappable components |

---

*DUNYA.md — approved project reference · Phase 1 · March 2026*
