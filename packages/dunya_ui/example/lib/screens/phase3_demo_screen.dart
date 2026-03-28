import 'package:dunya/l10n.dart';
import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class Phase3DemoScreen extends StatefulWidget {
  const Phase3DemoScreen({super.key});

  @override
  State<Phase3DemoScreen> createState() => _Phase3DemoScreenState();
}

class _Phase3DemoScreenState extends State<Phase3DemoScreen> {
  // Favorites demo
  Country? _favCountry;

  // Phone validation demo
  Country? _phoneCountry;
  final _phoneController = TextEditingController();
  PhoneValidationResult? _validationResult;

  // Scroll-to-selected demo
  Country? _scrollCountry;

  // FormField demo
  final _formKey = GlobalKey<FormState>();
  Country? _formCountry;
  PhoneNumber? _savedPhone;

  // Exclude demo
  Country? _excludeCountry;

  // Recents demo
  final _recents = CountryRecents(maxItems: 3);
  Country? _recentsCountry;

  // Localization demo
  String _locale = 'en';
  Country? _l10nCountry;

  @override
  void initState() {
    super.initState();
    _scrollCountry = CountryRepository.findByAlpha2('JP');

    // Register Arabic locale for demo
    CountryLocalizations.register('ar', kCountryNamesAr);
    CountryLocalizations.register('es', kCountryNamesEs);
    CountryLocalizations.register('fr', kCountryNamesFr);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phase 3 Features')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 1. Favorites ───
          const _SectionTitle('Favorites'),
          const SizedBox(height: 4),
          const _Desc(
            'KW, US, GB, IN pinned to top with a section separator. '
            'Also notice the A-Z alphabet bar on the right.',
          ),
          const SizedBox(height: 12),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _favCountry,
            onSelected: (c) => setState(() => _favCountry = c),
            favorites: const ['KW', 'US', 'GB', 'IN'],
          ),
          if (_favCountry != null) _selectedText(_favCountry!),
          const SizedBox(height: 32),

          // ─── 2. Phone Validation ───
          const _SectionTitle('Phone Validation'),
          const SizedBox(height: 4),
          const _Desc(
            'Select a country, type a number. Validates per keystroke. '
            'Input blocks letters and enforces max length.',
          ),
          const SizedBox(height: 12),
          DunyaDialCodeField(
            selectedCountry: _phoneCountry,
            onCountryChanged: (c) {
              setState(() {
                _phoneCountry = c;
                _validationResult = null;
              });
              if (_phoneController.text.isNotEmpty) {
                final result = PhoneValidator.validate(
                  _phoneController.text,
                  c.alpha2,
                );
                setState(() => _validationResult = result);
              }
            },
            controller: _phoneController,
            enableValidation: true,
            onValidationChanged: (result) {
              setState(() => _validationResult = result);
            },
            favorites: const ['KW', 'US', 'GB'],
            numberHint: 'Enter phone number',
          ),
          const SizedBox(height: 8),
          _ValidationStatus(
            result: _validationResult,
            country: _phoneCountry,
          ),
          if (_phoneCountry != null && _phoneController.text.isNotEmpty)
            _ParsedPhoneInfo(
              dialCode: _phoneCountry!.dialCode,
              rawInput: _phoneController.text,
              alpha2: _phoneCountry!.alpha2,
            ),
          const SizedBox(height: 32),

          // ─── 3. FormField Integration ───
          const _SectionTitle('FormField Integration'),
          const SizedBox(height: 4),
          const _Desc(
            'DunyaDialCodeFormField works with Flutter Form. '
            'Tap Submit to validate — shows error if invalid.',
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DunyaDialCodeFormField(
                  selectedCountry: _formCountry,
                  onCountryChanged: (c) =>
                      setState(() => _formCountry = c),
                  numberHint: 'Phone number',
                  favorites: const ['KW', 'US'],
                  validator: (phone) {
                    if (phone == null) return 'Enter a phone number';
                    if (!phone.isValid) return 'Invalid number for ${phone.alpha2}';
                    return null;
                  },
                  onSaved: (phone) =>
                      setState(() => _savedPhone = phone),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                    const SizedBox(width: 12),
                    if (_savedPhone != null)
                      Text(
                        'Saved: ${_savedPhone!.e164}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ─── 4. Exclude Countries ───
          const _SectionTitle('Exclude Countries'),
          const SizedBox(height: 4),
          const _Desc(
            'KP (North Korea) and IR (Iran) excluded from the list.',
          ),
          const SizedBox(height: 12),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _excludeCountry,
            onSelected: (c) => setState(() => _excludeCountry = c),
            exclude: const ['KP', 'IR'],
          ),
          if (_excludeCountry != null) _selectedText(_excludeCountry!),
          const SizedBox(height: 32),

          // ─── 5. Scroll-to-Selected ───
          const _SectionTitle('Scroll-to-Selected'),
          const SizedBox(height: 4),
          const _Desc(
            'Japan (JP) is pre-selected. Open the picker — the list '
            'auto-scrolls to Japan.',
          ),
          const SizedBox(height: 12),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _scrollCountry,
            onSelected: (c) => setState(() => _scrollCountry = c),
          ),
          if (_scrollCountry != null) _selectedText(_scrollCountry!),
          const SizedBox(height: 32),

          // ─── 6. Recents ───
          const _SectionTitle('Recent Selections'),
          const SizedBox(height: 4),
          const _Desc(
            'Select countries below — last 3 are tracked. '
            'Pass recents.codes as favorites to pin them.',
          ),
          const SizedBox(height: 12),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _recentsCountry,
            onSelected: (c) {
              _recents.add(c.alpha2);
              setState(() => _recentsCountry = c);
            },
            favorites: _recents.codes,
          ),
          if (_recents.codes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Recents: ${_recents.codes.join(', ')}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const SizedBox(height: 32),

          // ─── 7. Localization ───
          const _SectionTitle('Localization'),
          const SizedBox(height: 4),
          const _Desc(
            'Switch locale to see country names in Arabic, Spanish, '
            'or French. Search works in the active locale too.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _localeChip('en', 'English'),
              _localeChip('ar', 'العربية'),
              _localeChip('es', 'Español'),
              _localeChip('fr', 'Français'),
            ],
          ),
          const SizedBox(height: 12),
          // Wrap in a Localizations override to demo locale switching
          Localizations.override(
            context: context,
            locale: Locale(_locale),
            child: Builder(
              builder: (localizedContext) {
                return DunyaCountryPicker(
                  countries: CountryRepository.all,
                  selectedCountry: _l10nCountry,
                  onSelected: (c) => setState(() => _l10nCountry = c),
                  favorites: const ['KW', 'SA', 'AE'],
                  mode: DunyaPickerMode.dialog,
                );
              },
            ),
          ),
          if (_l10nCountry != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'English: ${_l10nCountry!.name}\n'
                'Localized ($_locale): ${CountryLocalizations.nameOf(_l10nCountry!.alpha2, _locale) ?? _l10nCountry!.name}',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          const SizedBox(height: 32),

          // ─── 8. Favorites + Dialog Mode ───
          const _SectionTitle('Favorites + Dialog'),
          const SizedBox(height: 4),
          const _Desc('Same favorites in dialog mode.'),
          const SizedBox(height: 12),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _favCountry,
            onSelected: (c) => setState(() => _favCountry = c),
            mode: DunyaPickerMode.dialog,
            favorites: const ['KW', 'US', 'GB', 'IN'],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _localeChip(String code, String label) {
    final selected = _locale == code;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _locale = code),
    );
  }

  Widget _selectedText(Country country) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Selected: ${country.name} ${country.dialCode}',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}

class _ValidationStatus extends StatelessWidget {
  final PhoneValidationResult? result;
  final Country? country;

  const _ValidationStatus({this.result, this.country});

  @override
  Widget build(BuildContext context) {
    if (country == null) {
      return const Text(
        'Select a country first',
        style: TextStyle(fontSize: 13, color: Colors.grey),
      );
    }

    final meta = PhoneValidator.metadataFor(country!.alpha2);
    final lengthInfo = meta != null
        ? 'Expected: ${meta.minLength}–${meta.maxLength} digits'
        : 'No metadata for ${country!.alpha2}';

    if (result == null) {
      return Text(
        lengthInfo,
        style: const TextStyle(fontSize: 13, color: Colors.grey),
      );
    }

    final color = result!.isValid ? Colors.green : Colors.red;
    final icon = result!.isValid ? Icons.check_circle : Icons.error;
    final message = result!.isValid
        ? 'Valid phone number'
        : _errorMessage(result!.error!);

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$message  ($lengthInfo)',
            style: TextStyle(fontSize: 13, color: color),
          ),
        ),
      ],
    );
  }

  String _errorMessage(PhoneValidationError error) {
    switch (error) {
      case PhoneValidationError.empty:
        return 'Empty';
      case PhoneValidationError.tooShort:
        return 'Too short';
      case PhoneValidationError.tooLong:
        return 'Too long';
      case PhoneValidationError.invalidCharacters:
        return 'Invalid characters';
      case PhoneValidationError.unknownCountry:
        return 'Unknown country';
    }
  }
}

class _ParsedPhoneInfo extends StatelessWidget {
  final String dialCode;
  final String rawInput;
  final String alpha2;

  const _ParsedPhoneInfo({
    required this.dialCode,
    required this.rawInput,
    required this.alpha2,
  });

  @override
  Widget build(BuildContext context) {
    final phone = PhoneNumber.parse(dialCode, rawInput, alpha2);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final codeColor = isDark ? Colors.cyan[200]! : Colors.indigo;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PhoneNumber.parse() output:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 6),
          _row('nationalNumber', phone.nationalNumber, codeColor),
          _row('internationalNumber', phone.internationalNumber, codeColor),
          _row('e164', phone.e164, codeColor),
          _row('dialCode', phone.dialCode, codeColor),
          _row('alpha2', phone.alpha2, codeColor),
          _row('isValid', '${phone.isValid}', codeColor),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color? codeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: codeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }
}

class _Desc extends StatelessWidget {
  final String text;
  const _Desc(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    );
  }
}
