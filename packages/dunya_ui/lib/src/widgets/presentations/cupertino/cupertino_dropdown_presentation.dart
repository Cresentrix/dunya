import 'dart:ui';

import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../theme/dunya_picker_theme.dart';
import '../../shared/country_list_view.dart';

/// iOS-style dropdown overlay presentation for the country picker.
///
/// Uses [GestureDetector] instead of [InkWell] for tap handling and
/// [CupertinoIcons] for the chevron. Supports optional frosted glass
/// background when [glassEffect] is `true`.
class CupertinoDropdownPresentation extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final ValueChanged<Country> onSelected;
  final String? searchHint;
  final Widget Function(BuildContext, Country)? itemBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool searchAutofocus;
  final bool glassEffect;
  final List<String> favorites;
  final String placeholder;
  final String? noResultsText;

  const CupertinoDropdownPresentation({
    required this.countries,
    required this.onSelected,
    super.key,
    this.selectedCountry,
    this.searchHint,
    this.itemBuilder,
    this.emptyBuilder,
    this.searchAutofocus = true,
    this.glassEffect = true,
    this.favorites = const [],
    this.placeholder = 'Select Country',
    this.noResultsText,
  });

  @override
  State<CupertinoDropdownPresentation> createState() =>
      _CupertinoDropdownPresentationState();
}

class _CupertinoDropdownPresentationState
    extends State<CupertinoDropdownPresentation> {
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  ScrollPosition? _scrollPosition;

  void _toggle() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final theme = DunyaPickerTheme.of(context);
    final renderBox = context.findRenderObject()! as RenderBox;
    final size = renderBox.size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final triggerPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final spaceBelow =
        screenHeight - keyboardHeight - triggerPosition.dy - size.height - 8;
    final spaceAbove = triggerPosition.dy - 8;
    final openDown = spaceBelow >= 200 || spaceBelow >= spaceAbove;
    final maxHeight = (openDown ? spaceBelow : spaceAbove).clamp(150.0, 400.0);
    final yOffset = openDown ? size.height + 4 : -maxHeight - 4;

    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final solidColor = theme.resolveSurfaceColor(context);
        final radius = theme.resolveDropdownRadius();

        Widget dropdownContent = SizedBox(
          width: size.width,
          height: maxHeight,
          child: CountryListView(
            countries: widget.countries,
            selectedCountry: widget.selectedCountry,
            onSelected: (country) {
              _removeOverlay();
              widget.onSelected(country);
            },
            searchHint: widget.searchHint,
            itemBuilder: widget.itemBuilder,
            emptyBuilder: widget.emptyBuilder,
            searchAutofocus: widget.searchAutofocus,
            useCupertino: true,
            favorites: widget.favorites,
            noResultsText: widget.noResultsText,
          ),
        );

        Widget dropdown;
        if (widget.glassEffect) {
          dropdown = ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: solidColor.withValues(alpha: 0.8),
                  borderRadius: radius,
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: dropdownContent,
              ),
            ),
          );
        } else {
          dropdown = DecoratedBox(
            decoration: BoxDecoration(
              color: solidColor,
              borderRadius: radius,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: dropdownContent,
            ),
          );
        }

        return DefaultTextStyle.merge(
          style: TextStyle(
            decoration: TextDecoration.none,
            color: isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => _removeOverlay(),
                ),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                offset: Offset(0, yOffset),
                child: dropdown,
              ),
            ],
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _onScroll() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && context.mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final displayName = widget.selectedCountry != null
        ? (CountryLocalizations.nameOf(
                widget.selectedCountry!.alpha2, locale) ??
            widget.selectedCountry!.name)
        : null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
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
              Expanded(
                child: Text(
                  displayName ?? widget.placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.selectedCountry != null
                        ? (isDark
                            ? const Color(0xFFEBEBF5)
                            : const Color(0xFF1C1C1E))
                        : const Color(0xFF8E8E93),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _overlayEntry != null
                    ? CupertinoIcons.chevron_up
                    : CupertinoIcons.chevron_down,
                size: 16,
                color: const Color(0xFF8E8E93),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
