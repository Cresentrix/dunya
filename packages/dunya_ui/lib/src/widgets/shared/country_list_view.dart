import 'package:dunya/dunya.dart';
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
  });

  @override
  State<CountryListView> createState() => _CountryListViewState();
}

class _CountryListViewState extends State<CountryListView> {
  List<Country> _results = [];
  late List<Country> _orderedCountries;
  int _favoritesCount = 0;
  final ScrollController _scrollController = ScrollController();
  bool _didScrollToSelected = false;

  @override
  void initState() {
    super.initState();
    _applyFavorites();
    _results = _orderedCountries;
  }

  @override
  void didUpdateWidget(CountryListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countries != widget.countries ||
        oldWidget.favorites != widget.favorites) {
      _applyFavorites();
      _results = _orderedCountries;
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
      final locale = Localizations.localeOf(context).languageCode;
      final searched = CountrySearch.search(
        widget.countries,
        query,
        locale: locale,
      );
      _results = query.trim().isEmpty ? _orderedCountries : searched;
    });
  }

  void _scrollToSelected() {
    if (_didScrollToSelected ||
        widget.selectedCountry == null ||
        !_scrollController.hasClients) {
      return;
    }
    _didScrollToSelected = true;

    final index = _results.indexWhere((c) => c == widget.selectedCountry);
    if (index < 0) return;

    final theme = DunyaPickerTheme.of(context);
    final itemHeight = theme.resolveItemHeight();
    final offset = index * itemHeight;
    final maxScroll = _scrollController.position.maxScrollExtent;

    _scrollController.jumpTo(offset.clamp(0.0, maxScroll));
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                          if (_favoritesCount > 0 &&
                              index == _favoritesCount - 1) {
                            return Container(
                              height: 8,
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
                    if (_results.length > 15)
                      _AlphabetScrollBar(
                        results: _results,
                        favoritesCount: _favoritesCount,
                        itemHeight: theme.resolveItemHeight(),
                        scrollController: _scrollController,
                        isDark: isDark,
                      ),
                  ],
                ),
        ),
      ],
    );
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
  final double itemHeight;
  final ScrollController scrollController;
  final bool isDark;

  const _AlphabetScrollBar({
    required this.results,
    required this.favoritesCount,
    required this.itemHeight,
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
        final letterHeight = maxLetterHeight.clamp(10.0, 16.0);
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

    // Find the first country starting with this letter
    for (var i = 0; i < results.length; i++) {
      if (results[i].name[0].toUpperCase() == targetLetter) {
        final offset = i * itemHeight;
        final maxScroll = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(offset.clamp(0.0, maxScroll));
        break;
      }
    }
  }
}
