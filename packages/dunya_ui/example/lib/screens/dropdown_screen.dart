import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class DropdownScreen extends StatefulWidget {
  const DropdownScreen({super.key});

  @override
  State<DropdownScreen> createState() => _DropdownScreenState();
}

class _DropdownScreenState extends State<DropdownScreen> {
  Country? _default;
  Country? _form;
  Country? _inline;
  Country? _flagAndCode;
  Country? _triggerBuilder;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dropdown')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Default
          const _Header(
            title: 'Default',
            description:
                'Inline overlay anchored below trigger. 320dp max height, tap outside to dismiss.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _default,
            mode: DunyaPickerMode.dropdown,
            onSelected: (c) => setState(() => _default = c),
          ),
          const SizedBox(height: 28),

          // Inside a form
          const _Header(
            title: 'Inside a Form',
            description:
                'Dropdown picker alongside other form fields. Validates country selection on submit.',
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Country',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _form,
            mode: DunyaPickerMode.dropdown,
            searchHint: 'Select your country...',
            onSelected: (c) => setState(() => _form = c),
          ),
          const SizedBox(height: 28),

          // Custom trigger
          const _Header(
            title: 'Custom Trigger',
            description:
                'Styled trigger with flag preview, custom radius and orange accent.',
          ),
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(
              extensions: [
                DunyaPickerTheme(
                  triggerRadius: BorderRadius.circular(24),
                  dropdownRadius: BorderRadius.circular(16),
                  selectedColor: const Color(0xFFFFF3E0),
                  selectedIndicatorColor: const Color(0xFFFF9800),
                ),
              ],
            ),
            child: DunyaCountryPicker(
              countries: CountryRepository.all,
              selectedCountry: _default,
              mode: DunyaPickerMode.dropdown,
              onSelected: (c) => setState(() => _default = c),
            ),
          ),
          const SizedBox(height: 28),

          // Inline with region filter
          const _Header(
            title: 'Inline — Europe Only',
            description:
                'Filtered to European countries. Shows how dropdown works with a subset.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all
                .where((c) => c.region == 'Europe')
                .toList(),
            selectedCountry: _inline,
            mode: DunyaPickerMode.dropdown,
            onSelected: (c) => setState(() => _inline = c),
          ),
          const SizedBox(height: 28),

          // Trigger style: flagAndCode
          const _Header(
            title: 'Trigger Style — flagAndCode',
            description:
                'Trigger shows flag + code, no arrow. Selection label enabled.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _flagAndCode,
            mode: DunyaPickerMode.dropdown,
            triggerStyle: DunyaPickerTriggerStyle.flagAndCode,
            selectionLabel: true,
            onSelected: (c) => setState(() => _flagAndCode = c),
          ),
          const SizedBox(height: 28),

          // Custom trigger builder
          const _Header(
            title: 'Custom Trigger Builder',
            description:
                'Outlined container trigger with globe icon. Dropdown opens on tap.',
          ),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _triggerBuilder,
            mode: DunyaPickerMode.dropdown,
            selectionLabel: false,
            triggerBuilder: (context, country, openPicker) {
              return InkWell(
                onTap: openPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (country != null) ...[
                        FlagWidget(alpha2: country.alpha2, size: 24),
                        const SizedBox(width: 8),
                        Text(country.name),
                        const Spacer(),
                        Text(country.dialCode,
                            style: TextStyle(color: Colors.grey[600])),
                      ] else ...[
                        const Icon(Icons.language, size: 20),
                        const SizedBox(width: 8),
                        const Text('Pick a country'),
                        const Spacer(),
                      ],
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more, size: 18),
                    ],
                  ),
                ),
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
