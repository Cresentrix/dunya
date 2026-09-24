import 'dart:async';

import '../data/country_repository.dart';
import '../models/country.dart';
import '../search/country_search.dart';

/// Manages country search, selection, and region filtering via streams.
///
/// Emits updated results on [results] and selection changes on [selected].
/// Search is debounced by 150 ms to avoid excessive filtering during typing.
///
/// Call [dispose] when the controller is no longer needed.
class CountryPickerController {
  /// Creates a controller pre-loaded with all countries.
  ///
  /// [results] only emits on changes; read [currentResults] for the
  /// initial list (e.g. as `StreamBuilder.initialData`).
  CountryPickerController();

  final _resultsController = StreamController<List<Country>>.broadcast();
  final _selectedController = StreamController<Country?>.broadcast();

  Country? _selected;
  String? _regionFilter;
  String? _locale;
  Timer? _debounceTimer;
  String _lastQuery = '';
  List<Country> _currentResults = CountryRepository.all;

  /// Stream of filtered/searched country lists, emitted on each change.
  Stream<List<Country>> get results => _resultsController.stream;

  /// Stream of selected country changes.
  Stream<Country?> get selected => _selectedController.stream;

  /// The full unfiltered country list.
  List<Country> get allCountries => CountryRepository.all;

  /// The latest search results, available before any stream event.
  List<Country> get currentResults => _currentResults;

  /// The currently selected country, or `null`.
  Country? get currentSelection => _selected;

  /// Sets the locale for localized search. Call when the app locale changes.
  set locale(String? value) => _locale = value;

  /// Searches countries by [query]. Respects [locale] for localized names.
  void search(String query) {
    _lastQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () {
      final source = _filteredByRegion();
      _emit(CountrySearch.search(source, query, locale: _locale));
    });
  }

  /// Selects a country and emits it on [selected].
  void select(Country country) {
    _selected = country;
    _selectedController.add(_selected);
  }

  /// Clears the selection and resets search results.
  void clear() {
    _selected = null;
    _selectedController.add(null);
    _lastQuery = '';
    // Cancel a pending search so it can't overwrite the cleared results.
    _debounceTimer?.cancel();
    _emit(_filteredByRegion());
  }

  /// Filters results to countries in [region]. Pass `null` to clear.
  void filterByRegion(String? region) {
    _regionFilter = region;
    search(_lastQuery);
  }

  /// Cancels timers and closes all streams.
  void dispose() {
    _debounceTimer?.cancel();
    _resultsController.close();
    _selectedController.close();
  }

  void _emit(List<Country> results) {
    _currentResults = results;
    _resultsController.add(results);
  }

  List<Country> _filteredByRegion() {
    if (_regionFilter == null) return CountryRepository.all;
    return CountryRepository.all
        .where((c) => c.region == _regionFilter)
        .toList(growable: false);
  }
}
