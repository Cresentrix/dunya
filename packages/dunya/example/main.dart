// ignore_for_file: avoid_print
import 'package:dunya/dunya.dart';

void main() {
  // All 250 countries
  final countries = CountryRepository.all;
  print('Total countries: ${countries.length}');

  // Lookup by alpha-2 code
  final kuwait = CountryRepository.findByAlpha2('KW');
  print('${kuwait!.name} ${kuwait.dialCode}'); // Kuwait +965

  // Lookup by dial code
  final india = CountryRepository.findByDialCode('+91');
  print('${india!.name} (${india.alpha2})'); // India (IN)

  // Search — ranked by match quality
  final results = CountrySearch.search(countries, 'united');
  for (final c in results) {
    print('  ${c.name} (${c.alpha2})');
  }

  // Phone validation
  final result = PhoneValidator.validate('50123456', 'KW');
  print('Valid: ${result.isValid}'); // true

  // Phone number parsing (E.164)
  final phone = PhoneNumber.parse('+965', '50 123-456', 'KW');
  print('E.164: ${phone.e164}'); // +96550123456

  // Favorites — pin countries to top
  final ordered = CountryFavorites.reorder(countries, ['KW', 'US', 'GB']);
  print('First: ${ordered.first.name}'); // Kuwait

  // Recents — track recently selected
  final recents = CountryRecents(maxItems: 3);
  recents.add('KW');
  recents.add('US');
  print('Recent: ${recents.codes}'); // [US, KW]
}
