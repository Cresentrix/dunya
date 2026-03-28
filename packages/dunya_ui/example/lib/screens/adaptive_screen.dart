import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class AdaptiveScreen extends StatefulWidget {
  const AdaptiveScreen({super.key});

  @override
  State<AdaptiveScreen> createState() => _AdaptiveScreenState();
}

class _AdaptiveScreenState extends State<AdaptiveScreen> {
  bool _adaptive = true;
  bool _glassEffect = true;

  Country? _bottomSheet;
  Country? _dialog;
  Country? _dropdown;
  Country? _dialCode;

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive Mode')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Toggle Controls ───
          const _SectionTitle('Settings'),
          const SizedBox(height: 4),
          const _Desc(
            'Toggle adaptive mode and glass effect. On iOS/macOS, '
            'adaptive: true renders Cupertino-style widgets. '
            'On Android/Web, it falls back to Material.',
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('adaptive'),
            subtitle: Text(
              _adaptive
                  ? 'Cupertino on iOS/macOS, Material elsewhere'
                  : 'Material everywhere',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _adaptive,
            onChanged: (v) => setState(() => _adaptive = v),
          ),
          SwitchListTile(
            title: const Text('glassEffect'),
            subtitle: Text(
              _glassEffect
                  ? 'Frosted blur background (Cupertino only)'
                  : 'Solid background',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _glassEffect,
            onChanged:
                _adaptive ? (v) => setState(() => _glassEffect = v) : null,
          ),
          const Divider(height: 32),

          // ─── Bottom Sheet ───
          const _SectionTitle('Bottom Sheet'),
          const SizedBox(height: 4),
          const _Desc('Adaptive bottom sheet with optional glass blur.'),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _bottomSheet,
            mode: DunyaPickerMode.bottomSheet,
            adaptive: _adaptive,
            glassEffect: _glassEffect,
            onSelected: (c) => setState(() => _bottomSheet = c),
          ),
          const SizedBox(height: 28),

          // ─── Dialog ───
          const _SectionTitle('Dialog'),
          const SizedBox(height: 4),
          const _Desc('Adaptive dialog with Cupertino Cancel button.'),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _dialog,
            mode: DunyaPickerMode.dialog,
            adaptive: _adaptive,
            glassEffect: _glassEffect,
            onSelected: (c) => setState(() => _dialog = c),
          ),
          const SizedBox(height: 28),

          // ─── Dropdown ───
          const _SectionTitle('Dropdown'),
          const SizedBox(height: 4),
          const _Desc('Adaptive dropdown with Cupertino chevron.'),
          const SizedBox(height: 8),
          DunyaCountryPicker(
            countries: CountryRepository.all,
            selectedCountry: _dropdown,
            mode: DunyaPickerMode.dropdown,
            adaptive: _adaptive,
            glassEffect: _glassEffect,
            onSelected: (c) => setState(() => _dropdown = c),
          ),
          const SizedBox(height: 28),

          // ─── Dial Code Field ───
          const _SectionTitle('Dial Code Field'),
          const SizedBox(height: 4),
          const _Desc(
            'Adaptive phone input — CupertinoTextField on iOS, '
            'Material TextField elsewhere.',
          ),
          const SizedBox(height: 8),
          DunyaDialCodeField(
            selectedCountry: _dialCode,
            onCountryChanged: (c) => setState(() => _dialCode = c),
            controller: _phoneController,
            adaptive: _adaptive,
            glassEffect: _glassEffect,
            numberHint: '50 123 4567',
            selectionLabel: false,
          ),
          const SizedBox(height: 32),
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
    return Text(text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
  }
}

class _Desc extends StatelessWidget {
  final String text;
  const _Desc(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[600]));
  }
}
