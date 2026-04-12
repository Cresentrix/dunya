import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/dunya_strings.dart';
import '../theme/dunya_picker_theme.dart';
import '../utils/platform_resolver.dart';
import 'presentations/bottom_sheet_presentation.dart';
import 'presentations/cupertino/cupertino_bottom_sheet_presentation.dart';
import 'presentations/cupertino/cupertino_dialog_presentation.dart';
import 'presentations/cupertino/cupertino_dropdown_presentation.dart';
import 'presentations/dialog_presentation.dart';
import 'presentations/dropdown_presentation.dart';
import 'shared/flag_widget.dart';

/// Determines the type of picker surface to display.
enum DunyaPickerMode {
  /// A draggable bottom sheet covering ~75% of the screen.
  bottomSheet,

  /// A centered dialog with fixed constraints.
  dialog,

  /// An inline dropdown overlay anchored to the trigger.
  dropdown,
}

/// Controls which elements are visible in the trigger button.
enum DunyaPickerTriggerStyle {
  /// Shows only the country flag.
  flagOnly,

  /// Shows only the dial code text.
  codeOnly,

  /// Shows the flag followed by the dial code.
  flagAndCode,

  /// Shows the dial code with a dropdown arrow.
  codeAndArrow,

  /// Shows flag, dial code, country name, and dropdown arrow.
  all,
}

/// A country picker widget supporting bottom sheet, dialog, and dropdown modes.
///
/// Set [adaptive] to `true` to automatically use Cupertino-style
/// presentations on iOS and macOS, and Material presentations elsewhere.
///
/// Set [glassEffect] to `false` to disable the frosted glass blur on
/// Cupertino presentations (ignored when rendering Material).
class DunyaCountryPicker extends StatelessWidget {
  /// The list of countries available for selection.
  final List<Country> countries;

  /// The currently selected country, highlighted in the list.
  final Country? selectedCountry;

  /// Called when the user selects a country.
  final ValueChanged<Country> onSelected;

  /// Which presentation mode to use.
  final DunyaPickerMode mode;

  /// Optional theme override (falls back to the nearest [DunyaPickerTheme]).
  final DunyaPickerTheme? theme;

  /// Placeholder text in the search bar.
  final String? searchHint;

  /// Optional custom builder for each country row.
  final Widget Function(BuildContext, Country)? itemBuilder;

  /// Optional builder shown when search yields no results.
  final WidgetBuilder? emptyBuilder;

  /// Controls which elements appear in the trigger button.
  final DunyaPickerTriggerStyle triggerStyle;

  /// Completely replaces the default trigger button.
  final Widget Function(BuildContext, Country?, VoidCallback)? triggerBuilder;

  /// Whether to show a small label below the trigger with the selection.
  final bool selectionLabel;

  /// Whether the search bar auto-focuses when the picker opens.
  final bool searchAutofocus;

  /// Use Cupertino styling on iOS/macOS when `true`.
  final bool adaptive;

  /// Enable frosted glass blur on Cupertino presentations.
  final bool glassEffect;

  /// Alpha-2 codes of countries to pin at the top.
  final List<String> favorites;

  /// Alpha-2 codes of countries to hide from the list.
  final List<String> exclude;

  /// Custom UI strings. Falls back to auto-detected locale strings.
  final DunyaStrings? strings;

  /// When `true`, the picker cannot be opened and the trigger appears disabled.
  final bool readOnly;

  const DunyaCountryPicker({
    required this.countries,
    required this.onSelected,
    super.key,
    this.selectedCountry,
    this.mode = DunyaPickerMode.bottomSheet,
    this.theme,
    this.searchHint,
    this.itemBuilder,
    this.emptyBuilder,
    this.triggerStyle = DunyaPickerTriggerStyle.all,
    this.triggerBuilder,
    this.selectionLabel = true,
    this.searchAutofocus = true,
    this.adaptive = false,
    this.glassEffect = true,
    this.favorites = const [],
    this.exclude = const [],
    this.strings,
    this.readOnly = false,
  });

  DunyaStrings _resolveStrings(BuildContext context) {
    if (strings != null) return strings!;
    final locale = Localizations.localeOf(context).languageCode;
    return DunyaStrings.forLocale(locale);
  }

  List<Country> get _filteredCountries {
    if (exclude.isEmpty) return countries;
    final codes = exclude.map((c) => c.toUpperCase()).toSet();
    return countries
        .where((c) => !codes.contains(c.alpha2))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final cupertino = PlatformResolver.useCupertino(adaptive);
    final filtered = _filteredCountries;
    final s = _resolveStrings(context);
    final resolvedSearchHint = searchHint ?? s.search;

    if (mode == DunyaPickerMode.dropdown) {
      return Opacity(
        opacity: readOnly ? 0.5 : 1.0,
        child: IgnorePointer(
          ignoring: readOnly,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cupertino)
                CupertinoDropdownPresentation(
                  countries: filtered,
                  selectedCountry: selectedCountry,
                  onSelected: onSelected,
                  searchHint: resolvedSearchHint,
                  itemBuilder: itemBuilder,
                  emptyBuilder: emptyBuilder,
                  searchAutofocus: searchAutofocus,
                  glassEffect: glassEffect,
                  favorites: favorites,
                  placeholder: s.selectCountry,
                  noResultsText: s.noResults,
                )
              else
                DropdownPresentation(
                  countries: filtered,
                  selectedCountry: selectedCountry,
                  onSelected: onSelected,
                  searchHint: resolvedSearchHint,
                  itemBuilder: itemBuilder,
                  emptyBuilder: emptyBuilder,
                  searchAutofocus: searchAutofocus,
                  favorites: favorites,
                  placeholder: s.selectCountry,
                  noResultsText: s.noResults,
                ),
              if (selectionLabel && selectedCountry != null)
                _SelectionLabel(country: selectedCountry!),
            ],
          ),
        ),
      );
    }

    final openPicker = readOnly ? null : () => _openPicker(context);
    final trigger = triggerBuilder != null
        ? triggerBuilder!(
            context, selectedCountry, openPicker ?? () {})
        : _TriggerButton(
            selectedCountry: selectedCountry,
            triggerStyle: triggerStyle,
            onTap: openPicker,
            useCupertino: cupertino,
            placeholder: s.selectCountry,
          );

    return Opacity(
      opacity: readOnly ? 0.5 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          trigger,
          if (selectionLabel && selectedCountry != null)
            _SelectionLabel(country: selectedCountry!),
        ],
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final cupertino = PlatformResolver.useCupertino(adaptive);
    final filtered = _filteredCountries;
    final s = _resolveStrings(context);
    final hint = searchHint ?? s.search;
    final Country? result;

    switch (mode) {
      case DunyaPickerMode.bottomSheet:
        if (cupertino) {
          result = await CupertinoBottomSheetPresentation.show(
            context: context,
            countries: filtered,
            selectedCountry: selectedCountry,
            searchHint: hint,
            itemBuilder: itemBuilder,
            emptyBuilder: emptyBuilder,
            searchAutofocus: searchAutofocus,
            glassEffect: glassEffect,
            favorites: favorites,
            title: s.selectCountry,
            noResultsText: s.noResults,
          );
        } else {
          result = await BottomSheetPresentation.show(
            context: context,
            countries: filtered,
            selectedCountry: selectedCountry,
            searchHint: hint,
            itemBuilder: itemBuilder,
            emptyBuilder: emptyBuilder,
            searchAutofocus: searchAutofocus,
            favorites: favorites,
            title: s.selectCountry,
            noResultsText: s.noResults,
          );
        }
      case DunyaPickerMode.dialog:
        if (cupertino) {
          result = await CupertinoDialogPresentation.show(
            context: context,
            countries: filtered,
            selectedCountry: selectedCountry,
            searchHint: hint,
            itemBuilder: itemBuilder,
            emptyBuilder: emptyBuilder,
            searchAutofocus: searchAutofocus,
            glassEffect: glassEffect,
            favorites: favorites,
            title: s.selectCountry,
            cancelText: s.cancel,
            noResultsText: s.noResults,
          );
        } else {
          result = await DialogPresentation.show(
            context: context,
            countries: filtered,
            selectedCountry: selectedCountry,
            searchHint: hint,
            itemBuilder: itemBuilder,
            emptyBuilder: emptyBuilder,
            searchAutofocus: searchAutofocus,
            favorites: favorites,
            title: s.selectCountry,
            cancelText: s.cancel,
            noResultsText: s.noResults,
          );
        }
      case DunyaPickerMode.dropdown:
        return;
    }

    if (result != null) {
      onSelected(result);
    }
  }
}

class _TriggerButton extends StatelessWidget {
  final Country? selectedCountry;
  final DunyaPickerTriggerStyle triggerStyle;
  final VoidCallback? onTap;
  final bool useCupertino;
  final String placeholder;

  const _TriggerButton({
    required this.selectedCountry,
    required this.triggerStyle,
    this.onTap,
    this.useCupertino = false,
    this.placeholder = 'Select Country',
  });

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = selectedCountry != null
        ? (isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E))
        : const Color(0xFF8E8E93);

    final child = Container(
      height: theme.resolveItemHeight(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: theme.resolveTriggerRadius(),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Row(
        children: [
          if (selectedCountry != null)
            ..._buildSelectedContent(
                context, selectedCountry!, theme, textColor)
          else
            Expanded(
              child: Text(
                placeholder,
                style: TextStyle(fontSize: 16, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (_showArrow)
            Icon(
              useCupertino
                  ? CupertinoIcons.chevron_down
                  : Icons.arrow_drop_down,
              size: useCupertino ? 16 : 24,
              color: const Color(0xFF8E8E93),
            ),
        ],
      ),
    );

    if (useCupertino) {
      return GestureDetector(onTap: onTap, child: child);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: theme.resolveTriggerRadius(),
      child: child,
    );
  }

  bool get _showArrow {
    switch (triggerStyle) {
      case DunyaPickerTriggerStyle.flagOnly:
      case DunyaPickerTriggerStyle.flagAndCode:
        return false;
      case DunyaPickerTriggerStyle.codeOnly:
      case DunyaPickerTriggerStyle.codeAndArrow:
      case DunyaPickerTriggerStyle.all:
        return true;
    }
  }

  List<Widget> _buildSelectedContent(
    BuildContext context,
    Country country,
    DunyaPickerTheme theme,
    Color textColor,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final displayName =
        CountryLocalizations.nameOf(country.alpha2, locale) ?? country.name;
    final widgets = <Widget>[];
    final showFlag = triggerStyle == DunyaPickerTriggerStyle.flagOnly ||
        triggerStyle == DunyaPickerTriggerStyle.flagAndCode ||
        triggerStyle == DunyaPickerTriggerStyle.all;
    final showCode = triggerStyle == DunyaPickerTriggerStyle.codeOnly ||
        triggerStyle == DunyaPickerTriggerStyle.flagAndCode ||
        triggerStyle == DunyaPickerTriggerStyle.codeAndArrow ||
        triggerStyle == DunyaPickerTriggerStyle.all;
    final showName = triggerStyle == DunyaPickerTriggerStyle.all ||
        triggerStyle == DunyaPickerTriggerStyle.codeAndArrow;

    if (showFlag) {
      widgets.add(FlagWidget(alpha2: country.alpha2, size: 24));
      widgets.add(const SizedBox(width: 8));
    }

    if (showCode) {
      widgets.add(Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          country.dialCode,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ));
      widgets.add(const SizedBox(width: 8));
    }

    if (showName) {
      widgets.add(Expanded(
        child: Text(
          displayName,
          style: TextStyle(fontSize: 16, color: textColor),
          overflow: TextOverflow.ellipsis,
        ),
      ));
    } else {
      widgets.add(const Spacer());
    }

    return widgets;
  }
}

class _SelectionLabel extends StatelessWidget {
  final Country country;
  const _SelectionLabel({required this.country});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final displayName =
        CountryLocalizations.nameOf(country.alpha2, locale) ?? country.name;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6, start: 2),
      child: Row(
        children: [
          FlagWidget(alpha2: country.alpha2, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              country.dialCode,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
