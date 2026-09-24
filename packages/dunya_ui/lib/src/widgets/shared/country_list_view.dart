import 'package:dunya/dunya.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';
import 'country_list_tile.dart';
import 'country_search_bar.dart';

/// Combines a [CountrySearchBar] with a scrollable list of countries.
///
/// When [useCupertino] is `true`, Cupertino styling is forwarded to the
/// search bar, list tiles, and dividers.
///
/// Pass [favorites] to pin specific countries to the top of the list.
/// A separator is drawn between favorites and the rest.
///
/// When [selectedCountry] is set, the list automatically scrolls to
/// that country on first build.
class CountryListView extends StatefulWidget {
  /// The full country list (before search filtering).
  final List<Country> countries;

  /// The currently selected country, used for highlighting and scroll-to.
  final Country? selectedCountry;

  /// Called when the user taps a country row.
  final ValueChanged<Country> onSelected;

  /// Placeholder text for the search bar.
  final String? searchHint;

  /// Optional custom builder for each country row.
  final Widget Function(BuildContext, Country)? itemBuilder;

  /// Optional builder shown when search yields no results.
  final WidgetBuilder? emptyBuilder;

  /// Whether the search bar auto-focuses on mount.
  final bool searchAutofocus;

  /// When `true`, renders Cupertino-style tiles and dividers.
  final bool useCupertino;

  /// Alpha-2 codes of countries to pin at the top of the list.
  final List<String> favorites;

  /// Whether to show a checkmark on the selected country row.
  final bool showSelectedIndicator;

  /// Text shown in the default empty state.
  final String? noResultsText;

  /// Optional scroll controller for the list, e.g. the one a
  /// [DraggableScrollableSheet] provides so dragging the list resizes it.
  /// Not disposed by this widget.
  final ScrollController? scrollController;

  const CountryListView({
    required this.countries,
    required this.onSelected,
    super.key,
    this.selectedCountry,
    this.searchHint,
    this.itemBuilder,
    this.emptyBuilder,
    this.searchAutofocus = true,
    this.useCupertino = false,
    this.favorites = const [],
    this.showSelectedIndicator = true,
    this.noResultsText,
    this.scrollController,
  });

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  List<Country> _results = [];
  late List<Country> _orderedCountries;
  int _favoritesCount = 0;
  String _query = '';
  ScrollController? _ownScrollController;
  bool _didScrollToSelected = false;

  ScrollController get _scrollController =>
      widget.scrollController ?? (_ownScrollController ??= ScrollController());

  /// Favorites are only pinned when no search is active.
  int get _activeFavoritesCount => _query.trim().isEmpty ? _favoritesCount : 0;

  @override
  void initState() {
    super.initState();
    _applyFavorites();
    _results = _orderedCountries;
  }

  @override
  void didUpdateWidget(CountryListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compare contents: parents often pass a new but equal list on each
    // build, which used to reset the list while a search was active.
    if (!listEquals(oldWidget.countries, widget.countries) ||
        !listEquals(oldWidget.favorites, widget.favorites)) {
      _applyFavorites();
      _results = _search(_query);
    }
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      _didScrollToSelected = false;
    }
  }

  void _applyFavorites() {
    _orderedCountries =
        CountryFavorites.reorder(widget.countries, widget.favorites);
    _favoritesCount =
        CountryFavorites.favoritesCount(_orderedCountries, widget.favorites);
  }

  void _onSearch(String query) {
    setState(() {
      _query = query;
      _results = _search(query);
    });
  }

  List<Country> _search(String query) {
    if (query.trim().isEmpty) return _orderedCountries;
    return CountrySearch.search(
      widget.countries,
      query,
      locale: Localizations.localeOf(context).toString(),
    );
  }

  /// Scroll offset of the row at [index], including the separators above it.
  double _offsetFor(int index, DunyaPickerTheme theme) {
    final itemHeight = theme.resolveItemHeight();
    if (!theme.resolveShowDividers()) return index * itemHeight;
    final dividerHeight = widget.useCupertino ? 0.5 : 1.0;
    var offset = index * (itemHeight + dividerHeight);
    final favorites = _activeFavoritesCount;
    if (favorites > 0 && index >= favorites) {
      // The separator after the favorites is 8px instead of a divider.
      offset += _favoritesSeparatorHeight - dividerHeight;
    }
    return offset;
  }

  static const double _favoritesSeparatorHeight = 8;

  void _scrollToSelected() {
    if (_didScrollToSelected ||
        widget.selectedCountry == null ||
        !_scrollController.hasClients) {
      return;
    }
    _didScrollToSelected = true;

    final index = _results.indexWhere((c) => c == widget.selectedCountry);
    if (index < 0) return;

    final offset = _offsetFor(index, DunyaPickerTheme.of(context));
    final maxScroll = _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
  }

  @override
  void dispose() {
    _ownScrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dividerColor = widget.useCupertino
        ? theme.resolveCupertinoSeparatorColor()
        : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF0EFF9));

    // Schedule scroll-to-selected after the list has been laid out.
    if (!_didScrollToSelected && widget.selectedCountry != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: CountrySearchBar(
            onChanged: _onSearch,
            hint: widget.searchHint,
            autofocus: widget.searchAutofocus,
            useCupertino: widget.useCupertino,
          ),
        ),
        if (theme.resolveShowDividers()) _buildDivider(dividerColor),
        Expanded(
          child: _results.isEmpty
              ? widget.emptyBuilder?.call(context) ??
                  _buildEmptyState(context, isDark)
              : Row(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (_, index) {
                          if (!theme.resolveShowDividers()) {
                            return const SizedBox.shrink();
                          }
                          // Thicker separator after favorites section
                          if (_activeFavoritesCount > 0 &&
                              index == _activeFavoritesCount - 1) {
                            return Container(
                              height: _favoritesSeparatorHeight,
                              color: isDark
                                  ? const Color(0xFF1C1C1E)
                                  : const Color(0xFFF2F2F7),
                            );
                          }
                          return _buildDivider(dividerColor);
                        },
                        itemBuilder: (context, index) {
                          final country = _results[index];

                          if (widget.itemBuilder != null) {
                            return widget.itemBuilder!(context, country);
                          }

                          return CountryListTile(
                            country: country,
                            isSelected: country == widget.selectedCountry,
                            onTap: () => widget.onSelected(country),
                            useCupertino: widget.useCupertino,
                            showSelectedIndicator: widget.showSelectedIndicator,
                          );
                        },
                      ),
                    ),
                    // Letters come from English names, so hide the bar
                    // when rows show translated names.
                    if (_results.length > 15 && !_showsLocalizedNames())
                      _AlphabetScrollBar(
                        results: _results,
                        favoritesCount: _activeFavoritesCount,
                        offsetFor: (i) => _offsetFor(i, theme),
                        scrollController: _scrollController,
                        isDark: isDark,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  bool _showsLocalizedNames() {
    if (_results.isEmpty) return false;
    final locale = Localizations.localeOf(context).toString();
    return CountryLocalizations.nameOf(_results.last.alpha2, locale) != null;
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
          ),
          const SizedBox(height: 12),
          Text(
            widget.noResultsText ?? 'No countries found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) {
    if (widget.useCupertino) {
      return Container(height: 0.5, color: color);
    }
    return Divider(height: 1, thickness: 1, color: color);
  }
}

/// A vertical strip of letters for quick-scrolling to a section.
///
/// Appears when the list has >15 items. Supports tap and vertical drag.
class _AlphabetScrollBar extends StatelessWidget {
  final List<Country> results;
  final int favoritesCount;
  final double Function(int index) offsetFor;
  final ScrollController scrollController;
  final bool isDark;

  const _AlphabetScrollBar({
    required this.results,
    required this.favoritesCount,
    required this.offsetFor,
    required this.scrollController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Build unique sorted letters from the non-favorites portion
    final letters = <String>{};
    for (var i = favoritesCount; i < results.length; i++) {
      final letter = results[i].name[0].toUpperCase();
      letters.add(letter);
    }
    final sortedLetters = letters.toList()..sort();

    if (sortedLetters.isEmpty) return const SizedBox.shrink();

    final color = isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - 8; // 4px padding each
        final maxLetterHeight = availableHeight / sortedLetters.length;
        // Too short to fit legible letters (e.g. a dropdown near the
        // bottom of the screen): hide the bar instead of overflowing.
        if (maxLetterHeight < 8) return const SizedBox.shrink();
        final letterHeight = maxLetterHeight.clamp(8.0, 16.0);
        final fontSize = (letterHeight * 0.65).clamp(7.0, 10.0);

        return GestureDetector(
          onVerticalDragUpdate: (details) {
            _onDragAdaptive(
              details.localPosition.dy,
              sortedLetters,
              constraints.maxHeight,
              letterHeight,
            );
          },
          onTapUp: (details) {
            _onDragAdaptive(
              details.localPosition.dy,
              sortedLetters,
              constraints.maxHeight,
              letterHeight,
            );
          },
          child: Container(
            width: 20,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: sortedLetters.map((letter) {
                return SizedBox(
                  height: letterHeight,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Maps a drag/tap y-position to a letter index and scrolls the list.
  void _onDragAdaptive(
    double dy,
    List<String> letters,
    double totalHeight,
    double letterHeight,
  ) {
    if (letters.isEmpty || !scrollController.hasClients) return;

    // Convert raw y to an index within the centered letter column.
    final barHeight = letters.length * letterHeight;
    final topPadding = (totalHeight - barHeight) / 2;
    final adjustedY = dy - topPadding;

    final index =
        (adjustedY / letterHeight).floor().clamp(0, letters.length - 1);
    final targetLetter = letters[index];

    // Find the first non-favorite country starting with this letter
    for (var i = favoritesCount; i < results.length; i++) {
      if (results[i].name[0].toUpperCase() == targetLetter) {
        final offset = offsetFor(i);
        final maxScroll = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(offset.clamp(0.0, maxScroll));
        break;
      }
    }
  }
}
