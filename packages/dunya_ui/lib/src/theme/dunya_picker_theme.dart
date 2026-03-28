import 'dart:ui';

import 'package:flutter/cupertino.dart' show CupertinoColors;
import 'package:flutter/material.dart';

/// A single [ThemeExtension] that drives the appearance of all Dunya widgets.
///
/// All properties are nullable — when `null`, sensible defaults are resolved
/// from the app's [ThemeData] brightness. Attach via `Theme.of(context)`:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: [
///       const DunyaPickerTheme(flagSize: 32, showDividers: false),
///     ],
///   ),
/// )
/// ```
class DunyaPickerTheme extends ThemeExtension<DunyaPickerTheme> {
  // ── Container ──

  /// Background color for the picker surface.
  final Color? surfaceColor;

  /// Overlay barrier color behind bottom sheets and dialogs.
  final Color? barrierColor;

  // ── Per-mode corner radii ──

  /// Corner radius for the bottom sheet presentation.
  final BorderRadius? bottomSheetRadius;

  /// Corner radius for the dialog presentation.
  final BorderRadius? dialogRadius;

  /// Corner radius for the dropdown overlay.
  final BorderRadius? dropdownRadius;

  /// Corner radius for the trigger button.
  final BorderRadius? triggerRadius;

  // ── List items ──

  /// Background color for the currently selected country row.
  final Color? selectedColor;

  /// Color of the checkmark icon on the selected row.
  final Color? selectedIndicatorColor;

  /// Height of each country row in the list.
  final double? itemHeight;

  /// Whether to show dividers between country rows.
  final bool? showDividers;

  // ── Flag ──

  /// Display size (width) of the flag SVG.
  final double? flagSize;

  /// Corner radius applied to the flag image.
  final BorderRadius? flagRadius;

  // ── Typography ──

  /// Text style for the country name in list rows.
  final TextStyle? countryNameStyle;

  /// Text style for the alpha-2 code in list rows.
  final TextStyle? codeStyle;

  /// Text style for the search bar hint text.
  final TextStyle? searchHintStyle;

  // ── Search bar ──

  /// Fill color of the search bar background.
  final Color? searchBarColor;

  /// Corner radius of the search bar.
  final BorderRadius? searchBarRadius;

  // ── Bottom sheet handle ──

  /// Color of the drag handle on bottom sheets.
  final Color? handleColor;

  /// Whether to show the drag handle on bottom sheets.
  final bool? showHandle;

  // ── Cupertino ──

  /// Separator color used in Cupertino list dividers.
  final Color? cupertinoSeparatorColor;

  /// Accent color for Cupertino action buttons (cancel, checkmark).
  final Color? cupertinoActionColor;

  const DunyaPickerTheme({
    this.surfaceColor,
    this.barrierColor,
    this.bottomSheetRadius,
    this.dialogRadius,
    this.dropdownRadius,
    this.triggerRadius,
    this.selectedColor,
    this.selectedIndicatorColor,
    this.itemHeight,
    this.showDividers,
    this.flagSize,
    this.flagRadius,
    this.countryNameStyle,
    this.codeStyle,
    this.searchHintStyle,
    this.searchBarColor,
    this.searchBarRadius,
    this.handleColor,
    this.showHandle,
    this.cupertinoSeparatorColor,
    this.cupertinoActionColor,
  });

  /// Retrieves the nearest [DunyaPickerTheme] from the widget tree,
  /// falling back to an empty (all-defaults) instance.
  static DunyaPickerTheme of(BuildContext context) =>
      Theme.of(context).extension<DunyaPickerTheme>() ??
      const DunyaPickerTheme();

  // Resolved defaults
  Color resolveSurfaceColor(BuildContext context) =>
      surfaceColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFFFFFFF));

  Color resolveBarrierColor(BuildContext context) =>
      barrierColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xA6000000)
          : const Color(0x59000000));

  BorderRadius resolveBottomSheetRadius() =>
      bottomSheetRadius ??
      const BorderRadius.vertical(top: Radius.circular(28));

  BorderRadius resolveDialogRadius() =>
      dialogRadius ?? BorderRadius.circular(20);

  BorderRadius resolveDropdownRadius() =>
      dropdownRadius ?? BorderRadius.circular(12);

  BorderRadius resolveTriggerRadius() =>
      triggerRadius ?? BorderRadius.circular(12);

  Color resolveSelectedColor(BuildContext context) =>
      selectedColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A3A)
          : const Color(0xFFF0EFFE));

  Color resolveSelectedIndicatorColor(BuildContext context) =>
      selectedIndicatorColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFA89FF0)
          : const Color(0xFF7F77DD));

  double resolveItemHeight() => itemHeight ?? 56;

  bool resolveShowDividers() => showDividers ?? true;

  double resolveFlagSize() => flagSize ?? 28;

  BorderRadius resolveFlagRadius() => flagRadius ?? BorderRadius.circular(4);

  Color resolveSearchBarColor(BuildContext context) =>
      searchBarColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2E)
          : const Color(0xFFF2F2F7));

  BorderRadius resolveSearchBarRadius() =>
      searchBarRadius ?? BorderRadius.circular(12);

  Color resolveHandleColor(BuildContext context) =>
      handleColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF48484A)
          : const Color(0xFFD1D1D6));

  bool resolveShowHandle() => showHandle ?? true;

  Color resolveCupertinoSeparatorColor() =>
      cupertinoSeparatorColor ?? CupertinoColors.separator;

  Color resolveCupertinoActionColor() =>
      cupertinoActionColor ?? CupertinoColors.systemBlue;

  @override
  DunyaPickerTheme copyWith({
    Color? surfaceColor,
    Color? barrierColor,
    BorderRadius? bottomSheetRadius,
    BorderRadius? dialogRadius,
    BorderRadius? dropdownRadius,
    BorderRadius? triggerRadius,
    Color? selectedColor,
    Color? selectedIndicatorColor,
    double? itemHeight,
    bool? showDividers,
    double? flagSize,
    BorderRadius? flagRadius,
    TextStyle? countryNameStyle,
    TextStyle? codeStyle,
    TextStyle? searchHintStyle,
    Color? searchBarColor,
    BorderRadius? searchBarRadius,
    Color? handleColor,
    bool? showHandle,
    Color? cupertinoSeparatorColor,
    Color? cupertinoActionColor,
  }) {
    return DunyaPickerTheme(
      surfaceColor: surfaceColor ?? this.surfaceColor,
      barrierColor: barrierColor ?? this.barrierColor,
      bottomSheetRadius: bottomSheetRadius ?? this.bottomSheetRadius,
      dialogRadius: dialogRadius ?? this.dialogRadius,
      dropdownRadius: dropdownRadius ?? this.dropdownRadius,
      triggerRadius: triggerRadius ?? this.triggerRadius,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedIndicatorColor:
          selectedIndicatorColor ?? this.selectedIndicatorColor,
      itemHeight: itemHeight ?? this.itemHeight,
      showDividers: showDividers ?? this.showDividers,
      flagSize: flagSize ?? this.flagSize,
      flagRadius: flagRadius ?? this.flagRadius,
      countryNameStyle: countryNameStyle ?? this.countryNameStyle,
      codeStyle: codeStyle ?? this.codeStyle,
      searchHintStyle: searchHintStyle ?? this.searchHintStyle,
      searchBarColor: searchBarColor ?? this.searchBarColor,
      searchBarRadius: searchBarRadius ?? this.searchBarRadius,
      handleColor: handleColor ?? this.handleColor,
      showHandle: showHandle ?? this.showHandle,
      cupertinoSeparatorColor:
          cupertinoSeparatorColor ?? this.cupertinoSeparatorColor,
      cupertinoActionColor: cupertinoActionColor ?? this.cupertinoActionColor,
    );
  }

  @override
  DunyaPickerTheme lerp(ThemeExtension<DunyaPickerTheme>? other, double t) {
    if (other is! DunyaPickerTheme) return this;
    return DunyaPickerTheme(
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t),
      barrierColor: Color.lerp(barrierColor, other.barrierColor, t),
      bottomSheetRadius:
          BorderRadius.lerp(bottomSheetRadius, other.bottomSheetRadius, t),
      dialogRadius: BorderRadius.lerp(dialogRadius, other.dialogRadius, t),
      dropdownRadius:
          BorderRadius.lerp(dropdownRadius, other.dropdownRadius, t),
      triggerRadius: BorderRadius.lerp(triggerRadius, other.triggerRadius, t),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
      selectedIndicatorColor:
          Color.lerp(selectedIndicatorColor, other.selectedIndicatorColor, t),
      itemHeight: lerpDouble(itemHeight, other.itemHeight, t),
      showDividers: t < 0.5 ? showDividers : other.showDividers,
      flagSize: lerpDouble(flagSize, other.flagSize, t),
      flagRadius: BorderRadius.lerp(flagRadius, other.flagRadius, t),
      countryNameStyle:
          TextStyle.lerp(countryNameStyle, other.countryNameStyle, t),
      codeStyle: TextStyle.lerp(codeStyle, other.codeStyle, t),
      searchHintStyle:
          TextStyle.lerp(searchHintStyle, other.searchHintStyle, t),
      searchBarColor: Color.lerp(searchBarColor, other.searchBarColor, t),
      searchBarRadius:
          BorderRadius.lerp(searchBarRadius, other.searchBarRadius, t),
      handleColor: Color.lerp(handleColor, other.handleColor, t),
      showHandle: t < 0.5 ? showHandle : other.showHandle,
      cupertinoSeparatorColor:
          Color.lerp(cupertinoSeparatorColor, other.cupertinoSeparatorColor, t),
      cupertinoActionColor:
          Color.lerp(cupertinoActionColor, other.cupertinoActionColor, t),
    );
  }
}
