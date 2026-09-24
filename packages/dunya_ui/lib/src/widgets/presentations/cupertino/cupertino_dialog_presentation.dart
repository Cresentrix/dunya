import 'dart:ui';

import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/dunya_picker_theme.dart';
import '../../shared/country_list_view.dart';
import '../../../utils/picker_theme_scope.dart';

/// iOS-style dialog presentation for the country picker.
///
/// Uses [showCupertinoDialog] with a custom full-content dialog.
/// Supports optional frosted glass background when [glassEffect] is `true`.
class CupertinoDialogPresentation {
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
    String cancelText = 'Cancel',
    String? noResultsText,
  }) {
    final theme = DunyaPickerTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return showCupertinoDialog<Country>(
      context: context,
      barrierDismissible: true,
      builder: themedBuilder(theme, (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final solidColor = theme.resolveSurfaceColor(context);
        final radius = theme.resolveDialogRadius();

        Widget body = Column(
          children: [
            _buildHeader(context, isDark, title),
            Expanded(
              child: CountryListView(
                countries: countries,
                selectedCountry: selectedCountry,
                onSelected: (country) => Navigator.of(context).pop(country),
                searchHint: searchHint,
                itemBuilder: itemBuilder,
                emptyBuilder: emptyBuilder,
                searchAutofocus: searchAutofocus,
                useCupertino: true,
                favorites: favorites,
                noResultsText: noResultsText,
              ),
            ),
            _buildFooter(context, theme, cancelText),
          ],
        );

        Widget dialog;
        if (glassEffect) {
          dialog = ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: solidColor.withValues(alpha: 0.8),
                  borderRadius: radius,
                ),
                child: body,
              ),
            ),
          );
        } else {
          dialog = Container(
            decoration: BoxDecoration(
              color: solidColor,
              borderRadius: radius,
            ),
            clipBehavior: Clip.antiAlias,
            child: body,
          );
        }

        return DefaultTextStyle(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E),
            fontSize: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
                maxHeight:
                    (screenHeight - MediaQuery.of(context).viewInsets.bottom) *
                        0.8,
                minWidth: 280,
                minHeight: 300,
              ),
              child: dialog,
            ),
          ),
        );
      }),
    );
  }

  static Widget _buildHeader(BuildContext context, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            child: const Icon(
              CupertinoIcons.xmark,
              size: 20,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFooter(
    BuildContext context,
    DunyaPickerTheme theme,
    String cancelText,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.resolveCupertinoSeparatorColor(),
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText,
              style: TextStyle(
                color: theme.resolveCupertinoActionColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
