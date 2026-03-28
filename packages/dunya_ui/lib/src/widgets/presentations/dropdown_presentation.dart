import 'package:dunya/dunya.dart';
import 'package:flutter/material.dart';

import '../../theme/dunya_picker_theme.dart';
import '../shared/country_list_view.dart';

/// Material dropdown overlay anchored to a trigger widget.
///
/// The overlay opens below the trigger when there is enough space (>= 200px),
/// otherwise opens above. Automatically dismisses when the user scrolls
/// a parent scrollable or taps outside.
class DropdownPresentation extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final ValueChanged<Country> onSelected;
  final String? searchHint;
  final Widget Function(BuildContext, Country)? itemBuilder;
  final WidgetBuilder? emptyBuilder;
  final bool searchAutofocus;
  final List<String> favorites;
  final String placeholder;
  final String? noResultsText;

  const DropdownPresentation({
    required this.countries,
    required this.onSelected,
    super.key,
    this.selectedCountry,
    this.searchHint,
    this.itemBuilder,
    this.emptyBuilder,
    this.searchAutofocus = true,
    this.favorites = const [],
    this.placeholder = 'Select Country',
    this.noResultsText,
  });

  @override
  State<DropdownPresentation> createState() => _DropdownPresentationState();
}

class _DropdownPresentationState extends State<DropdownPresentation>
    with WidgetsBindingObserver {
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
    final triggerPosition = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Determine if dropdown should open above or below the trigger
    // based on available screen space minus keyboard height.
    final spaceBelow =
        screenHeight - keyboardHeight - triggerPosition.dy - size.height - 8;
    final spaceAbove = triggerPosition.dy - 8;

    // Open downward if enough space, otherwise upward
    final openDown = spaceBelow >= 200 || spaceBelow >= spaceAbove;
    final maxHeight = (openDown ? spaceBelow : spaceAbove).clamp(150.0, 400.0);
    final yOffset = openDown ? size.height + 4 : -maxHeight - 4;

    // Listen to parent scroll to dismiss on scroll
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_onScroll);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Tap barrier — only catches taps, not drags/scrolls
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => _removeOverlay(),
              ),
            ),
            // Dropdown content
            CompositedTransformFollower(
              link: _layerLink,
              offset: Offset(0, yOffset),
              child: Material(
                elevation: 8,
                borderRadius: theme.resolveDropdownRadius(),
                clipBehavior: Clip.antiAlias,
                color: theme.resolveSurfaceColor(context),
                child: SizedBox(
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
                    favorites: widget.favorites,
                    noResultsText: widget.noResultsText,
                  ),
                ),
              ),
            ),
          ],
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
      child: InkWell(
        onTap: _toggle,
        borderRadius: theme.resolveTriggerRadius(),
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
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: const Color(0xFF8E8E93),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
