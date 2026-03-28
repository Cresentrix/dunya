/// A country with ISO codes, dial code, region info, and flag identifier.
///
/// Equality is based solely on [alpha2] — two [Country] instances with the
/// same alpha-2 code are considered equal regardless of other fields.
class Country {
  /// English common name (e.g. `'Kuwait'`).
  final String name;

  /// Native name in the country's own script (e.g. `'الكويت'`).
  final String nativeName;

  /// ISO 3166-1 alpha-2 code, uppercase (e.g. `'KW'`).
  final String alpha2;

  /// ISO 3166-1 alpha-3 code, uppercase (e.g. `'KWT'`).
  final String alpha3;

  /// ISO 3166-1 numeric code (e.g. `414`).
  final int numeric;

  /// UN region (e.g. `'Asia'`).
  final String region;

  /// UN subregion (e.g. `'Western Asia'`).
  final String subregion;

  /// International dial code with `+` prefix (e.g. `'+965'`).
  final String dialCode;

  /// Lowercase alpha-2 code used to resolve the flag SVG asset.
  final String flagCode;

  /// Creates a [Country] with all required fields.
  const Country({
    required this.name,
    required this.nativeName,
    required this.alpha2,
    required this.alpha3,
    required this.numeric,
    required this.region,
    required this.subregion,
    required this.dialCode,
    required this.flagCode,
  });

  /// Returns a copy with the given fields replaced.
  Country copyWith({
    String? name,
    String? nativeName,
    String? alpha2,
    String? alpha3,
    int? numeric,
    String? region,
    String? subregion,
    String? dialCode,
    String? flagCode,
  }) {
    return Country(
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      alpha2: alpha2 ?? this.alpha2,
      alpha3: alpha3 ?? this.alpha3,
      numeric: numeric ?? this.numeric,
      region: region ?? this.region,
      subregion: subregion ?? this.subregion,
      dialCode: dialCode ?? this.dialCode,
      flagCode: flagCode ?? this.flagCode,
    );
  }

  /// Deserializes a [Country] from a JSON map.
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      alpha2: json['alpha2'] as String,
      alpha3: json['alpha3'] as String,
      numeric: json['numeric'] as int,
      region: json['region'] as String,
      subregion: json['subregion'] as String,
      dialCode: json['dialCode'] as String,
      flagCode: json['flagCode'] as String,
    );
  }

  /// Serializes this [Country] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nativeName': nativeName,
      'alpha2': alpha2,
      'alpha3': alpha3,
      'numeric': numeric,
      'region': region,
      'subregion': subregion,
      'dialCode': dialCode,
      'flagCode': flagCode,
    };
  }

  @override
  bool operator ==(Object other) => other is Country && alpha2 == other.alpha2;

  @override
  int get hashCode => alpha2.hashCode;
}
