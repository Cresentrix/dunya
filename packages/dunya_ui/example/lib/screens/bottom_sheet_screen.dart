import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class BottomSheetScreen extends StatefulWidget {
  const BottomSheetScreen({super.key});

  @override
  State<BottomSheetScreen> createState() => _BottomSheetScreenState();
}

class _BottomSheetScreenState extends State<BottomSheetScreen> {
  Country? _default;
  Country? _themed;
  Country? _custom;
  Country? _preSelected;
  Country? _filtered;
  Country? _flagOnly;
  Country? _noLabel;
  Country? _triggerBuilder;

  @override
  void initState() {
    super.initState();
    _preSelected = CountryRepository.findByAlpha2('AE');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bottom Sheet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default
          const _Header(
            title: 'Default',
            description: 'Standard bottom sheet with default DunyaPickerTheme.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _default,
            mode: DunyaPickerMode.bottomSheet,
            onSelected: (c) => setState(() => _default = c),
          ),
          const SizedBox(height: 28),

          // Custom theme
          const _Header(
            title: 'Custom Theme',
            description:
                'Green selected color, large items, no dividers, no handle.',
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              extensions: [
                DunyaPickerTheme(
                  selectedColor: const Color(0xFFE8F5E9),
                  selectedIndicatorColor: const Color(0xFF4CAF50),
                  itemHeight: 64,
                  flagSize: 32,
                  showDividers: false,
                  showHandle: false,
                  bottomSheetRadius: BorderRadius.circular(16),
                ),
              ],
            ),
            child: DunyaCountryPicker(
              countries: CountryRepository.all,
              selectedCountry: _themed,
              mode: DunyaPickerMode.bottomSheet,
              onSelected: (c) => setState(() => _themed = c),
            ),
          ),
          const SizedBox(height: 28),

          // Custom item builder
          const _Header(
            title: 'Custom Item Builder',
            description:
                'Override the list tile with flag, name, native name, and dial code.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _custom,
            mode: DunyaPickerMode.bottomSheet,
            itemBuilder: (context, country) => InkWell(
              onTap: () => Navigator.of(context).pop(country),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    FlagWidget(alpha2: country.alpha2, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(country.name,
                              style: const TextStyle(fontSize: 15)),
                          Text(country.nativeName,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Text(country.dialCode,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            onSelected: (c) => setState(() => _custom = c),
          ),
          const SizedBox(height: 28),

          // Pre-selected country
          const _Header(
            title: 'Pre-selected Country',
            description: 'Opens with UAE already selected and highlighted.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _preSelected,
            mode: DunyaPickerMode.bottomSheet,
            onSelected: (c) => setState(() => _preSelected = c),
          ),
          const SizedBox(height: 28),

          // Region filter
          const _Header(
            title: 'Region Filter (Africa)',
            description: 'Only African countries passed to the picker.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all
                .where((c) => c.region == 'Africa')
                .toList(),
            selectedCountry: _filtered,
            mode: DunyaPickerMode.bottomSheet,
            onSelected: (c) => setState(() => _filtered = c),
          ),
          const SizedBox(height: 28),

          // Trigger style: flagOnly
          const _Header(
            title: 'Trigger Style — flagOnly',
            description: 'Trigger shows only the flag. No code or arrow.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _flagOnly,
            mode: DunyaPickerMode.bottomSheet,
            triggerStyle: DunyaPickerTriggerStyle.flagOnly,
            onSelected: (c) => setState(() => _flagOnly = c),
          ),
          const SizedBox(height: 28),

          // Selection label off
          const _Header(
            title: 'Selection Label Off',
            description:
                'selectionLabel: false hides the confirmation row below.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _noLabel,
            mode: DunyaPickerMode.bottomSheet,
            selectionLabel: false,
            onSelected: (c) => setState(() => _noLabel = c),
          ),
          const SizedBox(height: 28),

          // Custom trigger builder
          const _Header(
            title: 'Custom Trigger Builder',
            description:
                'triggerBuilder replaces the default trigger with a chip-style widget.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _triggerBuilder,
            mode: DunyaPickerMode.bottomSheet,
            selectionLabel: false,
            triggerBuilder: (context, country, openPicker) {
              return ActionChip(
                avatar: country != null
                    ? FlagWidget(alpha2: country.alpha2, size: 20)
                    : const Icon(Icons.public, size: 18),
                label: Text(country?.name ?? 'Select Country'),
                onPressed: openPicker,
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
