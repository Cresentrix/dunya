import 'package:dunya/dunya.dart';
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';
import '../shared/country_list_view.dart';

/// Material bottom sheet presentation for the country picker.
///
/// Uses [showModalBottomSheet] with a [DraggableScrollableSheet] that
/// starts at 75% height and can expand to 90%.
class BottomSheetPresentation {
  /// Shows the country picker as a modal bottom sheet.
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
              return Container(
                decoration: BoxDecoration(
                  color: theme.resolveSurfaceColor(context),
                  borderRadius: theme.resolveBottomSheetRadius(),
                ),
                child: Column(
                  children: [
                    if (theme.resolveShowHandle()) _buildHandle(theme, context),
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
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Widget _buildHandle(DunyaPickerTheme theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.resolveHandleColor(context),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  static Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFFEBEBF5)
                  : const Color(0xFF1C1C1E),
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
}
