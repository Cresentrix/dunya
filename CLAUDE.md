# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dunya ("the world" in Arabic) is a Flutter country picker published as two packages:
- **`packages/dunya`** — Pure Dart core: Country model, CountryRepository, CountrySearch, CountryPickerController. Zero Flutter UI dependency.
- **`packages/dunya_ui`** — Flutter widgets: DunyaCountryPicker (3 modes: bottomSheet/dialog/dropdown), DunyaDialCodeField, FlagWidget, DunyaPickerTheme. Depends on `dunya` and re-exports it.

Users only import `dunya_ui` to get everything. `dunya` alone is for data/logic without Flutter UI.

## Commands

Each package is developed independently from its own directory. There is no root-level pubspec; melos is described in the spec but not yet configured.

```bash
# Get dependencies
cd packages/dunya && flutter pub get
cd packages/dunya_ui && flutter pub get

# Run all tests
cd packages/dunya && flutter test
cd packages/dunya_ui && flutter test

# Run a single test file
cd packages/dunya && flutter test test/country_search_test.dart

# Format (CI enforces this)
dart format --set-exit-if-changed packages/dunya/lib
dart format --set-exit-if-changed packages/dunya_ui/lib

# Analyze (CI uses --fatal-infos)
cd packages/dunya && dart analyze --fatal-infos
cd packages/dunya_ui && dart analyze --fatal-infos

# Dry-run publish check
cd packages/dunya && dart pub publish --dry-run
cd packages/dunya_ui && dart pub publish --dry-run

# Run the example app
cd packages/dunya_ui/example && flutter run
```

## Architecture

```
Developer App (any state manager — BLoC, Riverpod, Provider, setState)
    │  passes List<Country> + onSelected callback
    ▼
dunya_ui (Flutter)
    DunyaCountryPicker → routes by DunyaPickerMode to:
    ├── BottomSheetPresentation ─┐
    ├── DialogPresentation       ├── all wrap CountryListView
    └── DropdownPresentation ────┘      ├── CountrySearchBar
                                        └── CountryListTile + FlagWidget
    DunyaDialCodeField (phone input with flag + dial code trigger)
    DunyaPickerTheme (single ThemeExtension drives all modes)
    │
    │ depends on
    ▼
dunya (pure Dart)
    CountryPickerController (streams, 150ms debounced search, region filter)
    CountryRepository (250 countries from bundled CC0 data)
    CountrySearch (ranked: alpha2 → dial code → name prefix → name contains → native name → alpha3)
    Country model
```

Key design rules:
- Zero state management inside packages — pure callbacks only
- Single `DunyaPickerTheme` ThemeExtension drives all 3 presentation modes
- 100% offline — no network calls ever
- Presentations are internal (not exported); shared widgets (FlagWidget, CountryListTile, CountrySearchBar) are public

## Code Style

- Linter: `flutter_lints` with strict rules — `implicit-casts: false`, `implicit-dynamic: false`
- `prefer_single_quotes`, `prefer_const_constructors`, `avoid_print`, `avoid_dynamic_calls`
- `dart format` must pass with no changes
- All public API must have `///` dartdoc comments (pub.dev scoring)
- Commit style: `type: short description` — types: feat, fix, chore, docs, test

## Data Sources

- Country data: `mledoze/countries` (CC0) — bundled as Dart const in `countries_data.dart`
- Flag SVGs: `lipis/flag-icons` (MIT, attribution required) — bundled in `dunya_ui/assets/flags/`
- Never use runtime APIs (restcountries.com, flagcdn.com, etc.)

## Testing

- `dunya` tests: unit tests for model (fromJson/toJson/equality), search (ranking, edge cases), controller (debounce, streams, dispose)
- `dunya_ui` tests: widget tests for FlagWidget, CountryListTile, DunyaCountryPicker (all 3 modes), DunyaDialCodeField
- Golden tests in `packages/dunya_ui/test/goldens/`
- Update goldens: `cd packages/dunya_ui && flutter test --update-goldens`

## Phase Roadmap

- Phase 1 (0.1.0, current): Material · iOS + Android · 3 modes · single theme
- Phase 2 (0.3.0): Cupertino widgets · adaptive mode · Web + desktop platforms
- Phase 3 (1.0.0): Multi-select · dial code formatter · favorites/recents
