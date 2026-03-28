/// Phone number metadata for a country.
///
/// Contains the minimum and maximum digit lengths (excluding dial code)
/// and an optional national format pattern for display.
class PhoneMetadata {
  /// ISO 3166-1 alpha-2 code this metadata applies to.
  final String alpha2;

  /// Minimum allowed digits in the national number.
  final int minLength;

  /// Maximum allowed digits in the national number.
  final int maxLength;

  /// Optional display format pattern (e.g. `'XXX XXX XXXX'`).
  final String? nationalFormat;

  /// Creates metadata for a single country's phone numbering plan.
  const PhoneMetadata({
    required this.alpha2,
    required this.minLength,
    required this.maxLength,
    this.nationalFormat,
  });
}
