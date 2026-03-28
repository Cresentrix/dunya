/// Resolves bundled flag SVG asset paths from alpha-2 codes.
class FlagResolver {
  /// Returns the package-relative asset path for a country's flag SVG.
  static String assetPath(String alpha2) =>
      'packages/dunya_ui/assets/flags/${alpha2.toLowerCase()}.svg';
}
