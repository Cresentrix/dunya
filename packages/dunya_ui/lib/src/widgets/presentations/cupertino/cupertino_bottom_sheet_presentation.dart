import 'dart:ui';

import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/dunya_picker_theme.dart';
import '../../shared/country_list_view.dart';

/// iOS-style bottom sheet presentation for the country picker.
///
/// Uses [showModalBottomSheet] with Cupertino chrome — no drag handle,
/// [CupertinoButton] close, and optional frosted glass background via
/// [BackdropFilter] when [glassEffect] is `true`.
class CupertinoBottomSheetPresentation {
  static Future<Country?> show({
    required BuildContext context,
    required List<Country> countries,
    Country? selectedCountry,
    String? searchHint,
    Widget Function(BuildContext, Country)? itemBuilder,
    WidgetBuilder? emptyBuilder,
    bool searchAutofocus = true,
    bool glassEffect = true,
    List<String> favorites = const [],
    String title = 'Select Country',
    String? noResultsText,
  }) {
    final theme = DunyaPickerTheme.of(context);

    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: theme.resolveBarrierColor(context),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final surfaceColor = theme.resolveSurfaceColor(context);
              final sheetRadius = theme.resolveBottomSheetRadius();

              Widget content = Column(
                children: [
                  _buildHeader(context, theme, title),
                  Expanded(
                    child: CountryListView(
                      countries: countries,
                      selectedCountry: selectedCountry,
                      onSelected: (country) =>
                          Navigator.of(context).pop(country),
                      searchHint: searchHint,
                      itemBuilder: itemBuilder,
                      emptyBuilder: emptyBuilder,
                      searchAutofocus: searchAutofocus,
                      useCupertino: true,
                      favorites: favorites,
                      noResultsText: noResultsText,
                    ),
                  ),
                ],
              );

              Widget sheet;

              if (glassEffect) {
                sheet = ClipRRect(
                  borderRadius: sheetRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor.withValues(alpha: 0.8),
                        borderRadius: sheetRadius,
                      ),
                      child: content,
                    ),
                  ),
                );
              } else {
                sheet = Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: sheetRadius,
                  ),
                  child: content,
                );
              }

              return DefaultTextStyle(
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: isDark
                      ? const Color(0xFFEBEBF5)
                      : const Color(0xFF1C1C1E),
                  fontSize: 16,
                ),
                child: sheet,
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildHeader(
    BuildContext context,
    DunyaPickerTheme theme,
    String title,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E),
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(
              CupertinoIcons.xmark,
              size: 20,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
