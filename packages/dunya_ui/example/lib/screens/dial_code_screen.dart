import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class DialCodeScreen extends StatefulWidget {
  const DialCodeScreen({super.key});

  @override
  State<DialCodeScreen> createState() => _DialCodeScreenState();
}

class _DialCodeScreenState extends State<DialCodeScreen> {
  // Section 1 — trigger styles
  Country? _flagOnly;
  Country? _codeOnly;
  Country? _flagAndCode;
  Country? _codeAndArrow;
  Country? _all;

  // Section 2 — selection label
  Country? _labelDefault;
  Country? _labelOff;

  // Section 3 — trigger builders
  Country? _card;
  Country? _outlined;
  Country? _avatar;

  final _phoneFlagOnly = TextEditingController();
  final _phoneCodeOnly = TextEditingController();
  final _phoneFlagAndCode = TextEditingController();
  final _phoneCodeAndArrow = TextEditingController();
  final _phoneAll = TextEditingController();
  final _phoneLabelDefault = TextEditingController();
  final _phoneLabelOff = TextEditingController();
  final _phoneCard = TextEditingController();
  final _phoneOutlined = TextEditingController();
  final _phoneAvatar = TextEditingController();

  @override
  void dispose() {
    _phoneFlagOnly.dispose();
    _phoneCodeOnly.dispose();
    _phoneFlagAndCode.dispose();
    _phoneCodeAndArrow.dispose();
    _phoneAll.dispose();
    _phoneLabelDefault.dispose();
    _phoneLabelOff.dispose();
    _phoneCard.dispose();
    _phoneOutlined.dispose();
    _phoneAvatar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dial Code Field')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Section 1: Trigger Style Variants ───
          const _SectionTitle('Trigger Style Variants'),
          const SizedBox(height: 4),
          const _Desc('Each field uses a different DunyaPickerTriggerStyle.'),
          const SizedBox(height: 12),

          const _Label('flagOnly — flag only, no code or arrow'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _flagOnly,
            onCountryChanged: (c) => setState(() => _flagOnly = c),
            controller: _phoneFlagOnly,
            triggerStyle: DunyaPickerTriggerStyle.flagOnly,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 16),

          const _Label('codeOnly — dial code + arrow, no flag'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _codeOnly,
            onCountryChanged: (c) => setState(() => _codeOnly = c),
            controller: _phoneCodeOnly,
            triggerStyle: DunyaPickerTriggerStyle.codeOnly,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 16),

          const _Label('flagAndCode — flag + code, no arrow'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _flagAndCode,
            onCountryChanged: (c) => setState(() => _flagAndCode = c),
            controller: _phoneFlagAndCode,
            triggerStyle: DunyaPickerTriggerStyle.flagAndCode,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 16),

          const _Label('codeAndArrow — code + arrow, no flag'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _codeAndArrow,
            onCountryChanged: (c) => setState(() => _codeAndArrow = c),
            controller: _phoneCodeAndArrow,
            triggerStyle: DunyaPickerTriggerStyle.codeAndArrow,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 16),

          const _Label('all — flag + code + arrow (default)'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _all,
            onCountryChanged: (c) => setState(() => _all = c),
            controller: _phoneAll,
            triggerStyle: DunyaPickerTriggerStyle.all,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 32),

          // ─── Section 2: Selection Label ───
          const _SectionTitle('Selection Label'),
          const SizedBox(height: 4),
          const _Desc(
            'selectionLabel: true shows a confirmation row below the field '
            'with flag + country name + dial code.',
          ),
          const SizedBox(height: 12),

          const _Label('selectionLabel: true (default)'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _labelDefault,
            onCountryChanged: (c) => setState(() => _labelDefault = c),
            controller: _phoneLabelDefault,
            selectionLabel: true,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 16),

          const _Label('selectionLabel: false'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _labelOff,
            onCountryChanged: (c) => setState(() => _labelOff = c),
            controller: _phoneLabelOff,
            selectionLabel: false,
            numberHint: '50 123 4567',
          ),
          const SizedBox(height: 32),

          // ─── Section 3: Custom Trigger Builders ───
          const _SectionTitle('Custom Trigger Builder'),
          const SizedBox(height: 4),
          const _Desc(
            'triggerBuilder replaces the default country section with a '
            'fully custom widget. openPicker() wired to onTap.',
          ),
          const SizedBox(height: 12),

          // Card style
          const _Label('Card style trigger'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _card,
            onCountryChanged: (c) => setState(() => _card = c),
            controller: _phoneCard,
            selectionLabel: false,
            numberHint: '50 123 4567',
            triggerBuilder: (context, country, openPicker) {
              return GestureDetector(
                onTap: openPicker,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (country != null) ...[
                        FlagWidget(alpha2: country.alpha2, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          country.dialCode,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else
                        const Icon(Icons.public, size: 20),
                      const SizedBox(width: 4),
                      const Icon(Icons.unfold_more, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Outlined button style
          const _Label('Outlined button trigger'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _outlined,
            onCountryChanged: (c) => setState(() => _outlined = c),
            controller: _phoneOutlined,
            selectionLabel: false,
            numberHint: '50 123 4567',
            triggerBuilder: (context, country, openPicker) {
              return OutlinedButton(
                onPressed: openPicker,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(44, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (country != null) ...[
                      FlagWidget(alpha2: country.alpha2, size: 20),
                      const SizedBox(width: 6),
                      Text(country.dialCode),
                    ] else
                      const Text('+--'),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Avatar + name style
          const _Label('Avatar + name trigger'),
          const SizedBox(height: 4),
          DunyaDialCodeField(
            selectedCountry: _avatar,
            onCountryChanged: (c) => setState(() => _avatar = c),
            controller: _phoneAvatar,
            selectionLabel: false,
            numberHint: '50 123 4567',
            triggerBuilder: (context, country, openPicker) {
              return GestureDetector(
                onTap: openPicker,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.grey[200],
                        child: country != null
                            ? ClipOval(
                                child: FlagWidget(
                                  alpha2: country.alpha2,
                                  size: 28,
                                  radius: BorderRadius.circular(14),
                                ),
                              )
                            : const Icon(Icons.language, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            country?.alpha2 ?? '--',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            country?.dialCode ?? '+--',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.expand_more,
                          size: 16, color: Colors.grey[500]),
                    ],
                  ),
                ),
              );
            },
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
    return Text(text,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]));
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500));
  }
}
