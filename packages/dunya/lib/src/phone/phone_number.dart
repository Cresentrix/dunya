import 'phone_validator.dart';

/// A parsed phone number with all the pieces a developer needs.
///
/// Created via [PhoneNumber.parse]. Combines the national number input
/// with the country's dial code to produce ready-to-use values.
///
/// ```dart
/// final phone = PhoneNumber.parse('+965', '50 123-456', 'KW');
/// phone.nationalNumber     // '50123456'
/// phone.internationalNumber // '+96550123456'
/// phone.e164               // '+96550123456'  (alias)
/// phone.dialCode           // '+965'
/// phone.alpha2             // 'KW'
/// phone.isValid            // true
/// ```
///
/// **Leading zeros:** The [nationalNumber] is the raw digits as the user
/// typed them. Some countries include a leading zero in the national
/// format (e.g. UK `07911123456`) while others don't (e.g. US `2025551234`).
/// This class does **not** strip or add leading zeros — it preserves
/// the user's input exactly. If your backend requires a specific format,
/// handle the leading zero on your side after reading [nationalNumber].
class PhoneNumber {
  /// The country's dial code including `+` prefix (e.g. `+965`).
  final String dialCode;

  /// The uppercase ISO 3166-1 alpha-2 country code (e.g. `KW`).
  final String alpha2;

  /// The national number with all formatting stripped — digits only.
  final String nationalNumber;

  /// The full international number: [dialCode] + [nationalNumber].
  /// E.g. `+96550123456`.
  final String internationalNumber;

  /// Alias for [internationalNumber] — the E.164 formatted number.
  String get e164 => internationalNumber;

  /// Whether the national number passes length validation for this country.
  final bool isValid;

  /// The validation error, if any. `null` when [isValid] is `true`.
  final PhoneValidationError? error;

  const PhoneNumber._({
    required this.dialCode,
    required this.alpha2,
    required this.nationalNumber,
    required this.internationalNumber,
    required this.isValid,
    this.error,
  });

  /// Parses a raw phone number input for a given country.
  ///
  /// [dialCode] — the country dial code (e.g. `+965`).
  /// [rawNationalNumber] — the user's input, may contain spaces, dashes, etc.
  /// [alpha2] — the ISO 3166-1 alpha-2 code (e.g. `KW`).
  factory PhoneNumber.parse(
    String dialCode,
    String rawNationalNumber,
    String alpha2,
  ) {
    final digits = stripFormatting(rawNationalNumber);
    final code = alpha2.toUpperCase();
    final cleanDialCode = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    final international = '$cleanDialCode$digits';

    final result = PhoneValidator.validate(rawNationalNumber, code);

    return PhoneNumber._(
      dialCode: cleanDialCode,
      alpha2: code,
      nationalNumber: digits,
      internationalNumber: international,
      isValid: result.isValid,
      error: result.error,
    );
  }

  /// Strips formatting and normalizes Eastern Arabic (٠-٩) and
  /// Extended Arabic-Indic (۰-۹) digits to ASCII (0-9).
  static String stripFormatting(String input) {
    final stripped = input.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');
    return _normalizeDigits(stripped);
  }

  /// Converts Arabic/Indic numerals to ASCII digits.
  static String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0660 && rune <= 0x0669) {
        // Eastern Arabic ٠-٩ → 0-9
        buffer.writeCharCode(rune - 0x0660 + 0x30);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        // Extended Arabic-Indic ۰-۹ → 0-9
        buffer.writeCharCode(rune - 0x06F0 + 0x30);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => 'PhoneNumber($internationalNumber, valid: $isValid)';

  @override
  bool operator ==(Object other) =>
      other is PhoneNumber &&
      internationalNumber == other.internationalNumber &&
      alpha2 == other.alpha2;

  @override
  int get hashCode => Object.hash(internationalNumber, alpha2);
}
