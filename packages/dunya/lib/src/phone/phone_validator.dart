import 'phone_metadata.dart';
import 'phone_metadata_data.dart';
import 'phone_number.dart';

/// Result of phone number validation.
class PhoneValidationResult {
  /// Whether the phone number passed all checks.
  final bool isValid;

  /// The error reason, or `null` when [isValid] is `true`.
  final PhoneValidationError? error;

  /// Creates a valid result.
  const PhoneValidationResult.valid()
      : isValid = true,
        error = null;

  /// Creates an invalid result with an [error] reason.
  const PhoneValidationResult.invalid(this.error) : isValid = false;
}

/// Possible phone validation errors.
enum PhoneValidationError {
  /// The input was empty.
  empty,

  /// Fewer digits than the country's minimum length.
  tooShort,

  /// More digits than the country's maximum length.
  tooLong,

  /// The input contains non-digit characters after stripping formatting.
  invalidCharacters,

  /// No phone metadata found for the given alpha-2 code.
  unknownCountry,
}

/// Validates phone numbers against per-country length rules.
///
/// Operates on the *national* number (digits after the dial code).
/// Strips spaces, dashes, and parentheses before validating.
class PhoneValidator {
  /// Returns the [PhoneMetadata] for a country, or `null` if unknown.
  ///
  /// The [alpha2] parameter is case-insensitive (`'ae'` and `'AE'` both work).
  ///
  /// ```dart
  /// final meta = PhoneValidator.metadataFor('AE');
  /// if (meta != null) {
  ///   print(meta.minLength); // 7
  ///   print(meta.maxLength); // 9
  ///   print(meta.nationalFormat); // 'XX XXX XXXX'
  /// }
  /// ```
  static PhoneMetadata? metadataFor(String alpha2) {
    return kPhoneMetadata[alpha2.toUpperCase()];
  }

  /// Validates a national phone number for the given country.
  ///
  /// Pass the *national* number (digits after the dial code) and the
  /// ISO 3166-1 alpha-2 code. Formatting (spaces, dashes, parentheses)
  /// and Arabic/Indic digits are normalized automatically.
  ///
  /// ```dart
  /// final result = PhoneValidator.validate('501234567', 'AE');
  /// if (result.isValid) {
  ///   print('Phone is valid');
  /// } else {
  ///   switch (result.error!) {
  ///     case PhoneValidationError.empty:
  ///       print('Enter a phone number');
  ///     case PhoneValidationError.tooShort:
  ///       print('Number is too short');
  ///     case PhoneValidationError.tooLong:
  ///       print('Number is too long');
  ///     case PhoneValidationError.invalidCharacters:
  ///       print('Only digits are allowed');
  ///     case PhoneValidationError.unknownCountry:
  ///       print('Country not recognized');
  ///   }
  /// }
  /// ```
  static PhoneValidationResult validate(String nationalNumber, String alpha2) {
    final digits = _stripFormatting(nationalNumber);

    if (digits.isEmpty) {
      return const PhoneValidationResult.invalid(PhoneValidationError.empty);
    }

    if (!_isDigitsOnly(digits)) {
      return const PhoneValidationResult.invalid(
        PhoneValidationError.invalidCharacters,
      );
    }

    final metadata = metadataFor(alpha2);
    if (metadata == null) {
      return const PhoneValidationResult.invalid(
        PhoneValidationError.unknownCountry,
      );
    }

    if (digits.length < metadata.minLength) {
      return const PhoneValidationResult.invalid(
        PhoneValidationError.tooShort,
      );
    }

    if (digits.length > metadata.maxLength) {
      return const PhoneValidationResult.invalid(
        PhoneValidationError.tooLong,
      );
    }

    return const PhoneValidationResult.valid();
  }

  /// Returns the max digit length for a country, or 15 (E.164 max) if unknown.
  ///
  /// Useful for setting input length limits on text fields.
  ///
  /// ```dart
  /// TextField(
  ///   inputFormatters: [
  ///     LengthLimitingTextInputFormatter(
  ///       PhoneValidator.maxLengthFor('AE'), // 9
  ///     ),
  ///   ],
  /// )
  /// ```
  static int maxLengthFor(String alpha2) {
    return metadataFor(alpha2)?.maxLength ?? 15;
  }

  /// Returns the min digit length for a country, or 1 if unknown.
  ///
  /// ```dart
  /// final min = PhoneValidator.minLengthFor('AE'); // 7
  /// final max = PhoneValidator.maxLengthFor('AE'); // 9
  /// print('UAE numbers are $min–$max digits');
  /// ```
  static int minLengthFor(String alpha2) {
    return metadataFor(alpha2)?.minLength ?? 1;
  }

  static String _stripFormatting(String input) {
    return PhoneNumber.stripFormatting(input);
  }

  /// Accepts ASCII digits (0-9). Input must be pre-normalized
  /// (Arabic/Indic digits converted to ASCII by [_stripFormatting]).
  static bool _isDigitsOnly(String s) {
    return RegExp(r'^\d+$').hasMatch(s);
  }
}
