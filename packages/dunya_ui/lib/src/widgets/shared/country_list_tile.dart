import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';
import 'flag_widget.dart';

/// A single row in the country list.
///
/// When [useCupertino] is `true`, uses [GestureDetector] with an iOS-style
/// highlight instead of Material [InkWell] ripple, and renders
/// [CupertinoIcons.checkmark] for the selection indicator.
class CountryListTile extends StatefulWidget {
  /// The country to display.
  final Country country;

  /// Whether this row is the currently selected country.
  final bool isSelected;

  /// Called when the user taps this row.
  final VoidCallback onTap;

  /// When `true`, uses Cupertino tap highlight and checkmark icon.
  final bool useCupertino;

  /// When `false`, hides the selection checkmark even when [isSelected].
  final bool showSelectedIndicator;

  const CountryListTile({
    required this.country,
    required this.isSelected,
    required this.onTap,
    super.key,
    this.useCupertino = false,
    this.showSelectedIndicator = true,
  });

  @override
  State<CountryListTile> createState() => _CountryListTileState();
}

class _CountryListTileState extends State<CountryListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final locale = Localizations.localeOf(context).languageCode;
    final displayName = CountryLocalizations.nameOf(
          widget.country.alpha2,
          locale,
        ) ??
        widget.country.name;

    final content = Container(
      height: theme.resolveItemHeight(),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: _resolveBackgroundColor(theme, isDark),
      child: Row(
        children: [
          FlagWidget(alpha2: widget.country.alpha2),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayName,
              style: theme.countryNameStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? const Color(0xFFEBEBF5)
                        : const Color(0xFF1C1C1E),
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.country.alpha2,
            style: theme.codeStyle ??
                const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                ),
          ),
          if (widget.isSelected && widget.showSelectedIndicator) ...[
            const SizedBox(width: 8),
            Icon(
              widget.useCupertino ? CupertinoIcons.checkmark : Icons.check,
              size: 20,
              color: widget.useCupertino
                  ? theme.resolveCupertinoActionColor()
                  : theme.resolveSelectedIndicatorColor(context),
            ),
          ],
        ],
      ),
    );

    final semanticsLabel = '$displayName, ${widget.country.dialCode}'
        '${widget.isSelected ? ', selected' : ''}';

    if (widget.useCupertino) {
      return Semantics(
        label: semanticsLabel,
        button: true,
        selected: widget.isSelected,
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: content,
        ),
      );
    }

    return Semantics(
      label: semanticsLabel,
      button: true,
      selected: widget.isSelected,
      child: InkWell(
        onTap: widget.onTap,
        child: content,
      ),
    );
  }

  Color? _resolveBackgroundColor(DunyaPickerTheme theme, bool isDark) {
    if (widget.isSelected && widget.showSelectedIndicator) {
      return theme.resolveSelectedColor(context);
    }
    if (widget.useCupertino && _pressed) {
      return isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    }
    return null;
  }
}
