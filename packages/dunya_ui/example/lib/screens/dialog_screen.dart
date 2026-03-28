import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class DialogScreen extends StatefulWidget {
  const DialogScreen({super.key});

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  Country? _default;
  Country? _customRadius;
  Country? _dark;
  Country? _codeAndArrow;
  Country? _triggerBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialog')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default
          const _Header(
            title: 'Default',
            description:
                'Standard dialog with search, close button, and cancel. 80% height.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _default,
            mode: DunyaPickerMode.dialog,
            onSelected: (c) => setState(() => _default = c),
          ),
          const SizedBox(height: 28),

          // Custom radius
          const _Header(
            title: 'Custom Radius',
            description: 'Pill-shaped dialog with radius 32 and blue accent.',
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              extensions: [
                DunyaPickerTheme(
                  dialogRadius: BorderRadius.circular(32),
                  selectedColor: const Color(0xFFE3F2FD),
                  selectedIndicatorColor: const Color(0xFF2196F3),
                ),
              ],
            ),
            child: DunyaCountryPicker(
              countries: CountryRepository.all,
              selectedCountry: _customRadius,
              mode: DunyaPickerMode.dialog,
              onSelected: (c) => setState(() => _customRadius = c),
            ),
          ),
          const SizedBox(height: 28),

          // Forced dark
          const _Header(
            title: 'Forced Dark',
            description:
                'Dark themed dialog regardless of system theme. Dark surface, light text.',
          ),
          const SizedBox(height: 8),
          Theme(
            data: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              extensions: const [
                DunyaPickerTheme(
                  surfaceColor: Color(0xFF1C1C1E),
                  barrierColor: Color(0xA6000000),
                  selectedColor: Color(0xFF2A2A3A),
                  selectedIndicatorColor: Color(0xFFA89FF0),
                  searchBarColor: Color(0xFF2C2C2E),
                  handleColor: Color(0xFF48484A),
                ),
              ],
            ),
            child: Builder(
              builder: (context) => DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _dark,
                mode: DunyaPickerMode.dialog,
                onSelected: (c) => setState(() => _dark = c),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Custom search hint
          const _Header(
            title: 'Custom Search Hint',
            description: 'Custom placeholder text in the search bar.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _default,
            mode: DunyaPickerMode.dialog,
            searchHint: 'Type country name or code...',
            onSelected: (c) => setState(() => _default = c),
          ),
          const SizedBox(height: 28),

          // Trigger style: codeAndArrow
          const _Header(
            title: 'Trigger Style — codeAndArrow',
            description:
                'Trigger shows dial code + arrow, no flag. Compact for forms.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _codeAndArrow,
            mode: DunyaPickerMode.dialog,
            triggerStyle: DunyaPickerTriggerStyle.codeAndArrow,
            onSelected: (c) => setState(() => _codeAndArrow = c),
          ),
          const SizedBox(height: 28),

          // Custom trigger builder
          const _Header(
            title: 'Custom Trigger Builder',
            description:
                'ElevatedButton trigger with icon. openPicker() wired to onPressed.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _triggerBuilder,
            mode: DunyaPickerMode.dialog,
            selectionLabel: true,
            triggerBuilder: (context, country, openPicker) {
              return ElevatedButton.icon(
                onPressed: openPicker,
                icon: country != null
                    ? FlagWidget(alpha2: country.alpha2, size: 20)
                    : const Icon(Icons.public),
                label: Text(country?.name ?? 'Choose country'),
              );
            },
            onSelected: (c) => setState(() => _triggerBuilder = c),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String description;
  const _Header({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
      ],
    );
  }
}
