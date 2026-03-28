import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/dunya_picker_theme.dart';
import '../../utils/flag_resolver.dart';

/// Renders a country's flag as a bundled SVG asset.
///
/// Uses [DunyaPickerTheme] for default [size] and [radius] when not
/// explicitly provided.
class FlagWidget extends StatelessWidget {
  /// ISO 3166-1 alpha-2 code of the country (e.g. `'KW'`).
  final String alpha2;

  /// Width of the flag image. Height is derived as `size * 0.67`.
  final double? size;

  /// Corner radius applied to the flag image clip.
  final BorderRadius? radius;

  const FlagWidget({
    required this.alpha2,
    super.key,
    this.size,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DunyaPickerTheme.of(context);
    final width = size ?? theme.resolveFlagSize();
    final height = width * 0.67;
    final r = radius ?? theme.resolveFlagRadius();

    return Semantics(
      label: '${alpha2.toUpperCase()} flag',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: r,
        child: SvgPicture.asset(
          FlagResolver.assetPath(alpha2),
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholderBuilder: (_) => _placeholder(width, height, r),
        ),
      ),
    );
  }

  Widget _placeholder(double width, double height, BorderRadius r) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: r,
      ),
    );
  }
}
