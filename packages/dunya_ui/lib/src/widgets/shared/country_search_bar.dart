import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';

/// A search bar used inside the country list.
///
/// When [useCupertino] is `true`, renders a [CupertinoSearchTextField].
/// Otherwise renders a Material [TextField].
class CountrySearchBar extends StatelessWidget {
  /// Called on every keystroke with the current search text.
  final ValueChanged<String> onChanged;

  /// Placeholder text shown when the search field is empty.
  final String? hint;

  /// Whether the search field requests focus on mount.
  final bool autofocus;

  /// When `true`, renders a [CupertinoSearchTextField] instead of Material.
  final bool useCupertino;

  const CountrySearchBar({
    required this.onChanged,
    super.key,
    this.hint,
    this.autofocus = true,
    this.useCupertino = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final hintText = hint ?? 'Search...';

    if (useCupertino) {
      return SizedBox(
        height: 44,
        child: CupertinoSearchTextField(
          autofocus: autofocus,
          onChanged: onChanged,
          placeholder: hintText,
          placeholderStyle: theme.searchHintStyle ??
              const TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
              ),
          style: theme.countryNameStyle,
          backgroundColor: theme.resolveSearchBarColor(context),
          borderRadius: theme.resolveSearchBarRadius(),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: TextField(
        autofocus: autofocus,
        onChanged: onChanged,
        style: theme.countryNameStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: theme.searchHintStyle ??
              TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF8E8E93),
              ),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: theme.resolveSearchBarColor(context),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: theme.resolveSearchBarRadius(),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
