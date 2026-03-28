import 'package:dunya/dunya.dart';
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';
import '../shared/country_list_view.dart';

/// Material dialog presentation for the country picker.
///
/// Uses [showDialog] with responsive constraints — the dialog scales to
/// 85% of screen width and 80% of available height (accounting for keyboard).
class DialogPresentation {
  /// Shows the country picker as a centered dialog.
  static Future<Country?> show({
    required BuildContext context,
    required List<Country> countries,
    Country? selectedCountry,
    String? searchHint,
    Widget Function(BuildContext, Country)? itemBuilder,
    WidgetBuilder? emptyBuilder,
    bool searchAutofocus = true,
    List<String> favorites = const [],
    String title = 'Select Country',
    String cancelText = 'Cancel',
    String? noResultsText,
  }) {
    final theme = DunyaPickerTheme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return showDialog<Country>(
      context: context,
      barrierColor: theme.resolveBarrierColor(context),
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.85,
                maxHeight:
                    (screenHeight - MediaQuery.of(context).viewInsets.bottom) *
                        0.8,
                minWidth: 280,
                minHeight: 300,
              ),
              decoration: BoxDecoration(
                color: theme.resolveSurfaceColor(context),
                borderRadius: theme.resolveDialogRadius(),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildHeader(context, title),
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
                      favorites: favorites,
                      noResultsText: noResultsText,
                    ),
                  ),
                  _buildFooter(context, cancelText),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFooter(BuildContext context, String cancelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
        ],
      ),
    );
  }
}
