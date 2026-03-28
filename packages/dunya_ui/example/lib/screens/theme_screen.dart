import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  Country? _sheetSelected;
  Country? _dialogSelected;
  Country? _dropdownSelected;
  Country? _dialSelected;
  final _phoneController = TextEditingController();
  bool _dark = false;

  // Radius
  double _sheetRadius = 28;
  double _dialogRadius = 20;
  double _dropdownRadius = 12;
  double _searchBarRadius = 12;
  double _flagRadius = 4;

  // Sizes
  double _flagSize = 28;
  double _itemHeight = 56;

  // Toggles
  bool _showDividers = true;
  bool _showHandle = true;

  // Colors
  int _selectedColorIndex = 0;
  int _indicatorColorIndex = 0;
  int _searchBarColorIndex = 0;

  static const _selectedColors = [
    Color(0xFFF0EFFE),
    Color(0xFFE8F5E9),
    Color(0xFFFFF3E0),
    Color(0xFFE3F2FD),
    Color(0xFFFCE4EC),
  ];

  static const _indicatorColors = [
    Color(0xFF7F77DD),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
  ];

  static const _searchBarColors = [
    Color(0xFFF2F2F7),
    Color(0xFFE8EAF6),
    Color(0xFFF3E5F5),
    Color(0xFFE0F2F1),
    Color(0xFFFFF8E1),
  ];

  DunyaPickerTheme _buildTheme() {
    return DunyaPickerTheme(
      bottomSheetRadius:
          BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
      dialogRadius: BorderRadius.circular(_dialogRadius),
      dropdownRadius: BorderRadius.circular(_dropdownRadius),
      searchBarRadius: BorderRadius.circular(_searchBarRadius),
      flagRadius: BorderRadius.circular(_flagRadius),
      flagSize: _flagSize,
      itemHeight: _itemHeight,
      showDividers: _showDividers,
      showHandle: _showHandle,
      selectedColor: _selectedColors[_selectedColorIndex],
      selectedIndicatorColor: _indicatorColors[_indicatorColorIndex],
      searchBarColor: _searchBarColors[_searchBarColorIndex],
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = _buildTheme();

    return Theme(
      data: (_dark ? ThemeData.dark(useMaterial3: true) : Theme.of(context))
          .copyWith(extensions: [customTheme]),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Theme Customizer'),
            leading: BackButton(
              onPressed: () => Navigator.of(this.context).pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Preview — Bottom Sheet
              const _Label('Bottom Sheet'),
              const SizedBox(height: 8),
              DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _sheetSelected,
                mode: DunyaPickerMode.bottomSheet,
                onSelected: (c) => setState(() => _sheetSelected = c),
              ),
              const SizedBox(height: 16),

              // Preview — Dialog
              const _Label('Dialog'),
              const SizedBox(height: 8),
              DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _dialogSelected,
                mode: DunyaPickerMode.dialog,
                onSelected: (c) => setState(() => _dialogSelected = c),
              ),
              const SizedBox(height: 16),

              // Preview — Dropdown
              const _Label('Dropdown'),
              const SizedBox(height: 8),
              DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _dropdownSelected,
                mode: DunyaPickerMode.dropdown,
                selectionLabel: false,
                onSelected: (c) => setState(() => _dropdownSelected = c),
              ),
              const SizedBox(height: 16),

              // Preview — Dial Code Field
              const _Label('Dial Code Field'),
              const SizedBox(height: 8),
              DunyaDialCodeField(
                selectedCountry: _dialSelected,
                onCountryChanged: (c) => setState(() => _dialSelected = c),
                controller: _phoneController,
                numberHint: '50 123 4567',
              ),
              const SizedBox(height: 16),

              // Preview — Flag Widget
              const _Label('Flag Widget'),
              const SizedBox(height: 8),
              Row(
                children: [
                  FlagWidget(
                    alpha2: _sheetSelected?.alpha2 ?? 'AE',
                    size: _flagSize,
                    radius: BorderRadius.circular(_flagRadius),
                  ),
                  const SizedBox(width: 12),
                  FlagWidget(
                    alpha2: _dialogSelected?.alpha2 ?? 'US',
                    size: _flagSize,
                    radius: BorderRadius.circular(_flagRadius),
                  ),
                  const SizedBox(width: 12),
                  FlagWidget(
                    alpha2: _dropdownSelected?.alpha2 ?? 'JP',
                    size: _flagSize,
                    radius: BorderRadius.circular(_flagRadius),
                  ),
                  const SizedBox(width: 12),
                  FlagWidget(
                    alpha2: _dialSelected?.alpha2 ?? 'EG',
                    size: _flagSize,
                    radius: BorderRadius.circular(_flagRadius),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Dark / Light
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: _dark,
                onChanged: (v) => setState(() => _dark = v),
              ),
              const SizedBox(height: 8),

              // Toggles
              SwitchListTile(
                title: const Text('Show Dividers'),
                subtitle: const Text('Lines between list items'),
                value: _showDividers,
                onChanged: (v) => setState(() => _showDividers = v),
              ),
              SwitchListTile(
                title: const Text('Show Handle'),
                subtitle: const Text('Drag handle on bottom sheet'),
                value: _showHandle,
                onChanged: (v) => setState(() => _showHandle = v),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Sizes
              const _Label('Sizes'),
              const SizedBox(height: 8),
              _Slider(
                label: 'Flag Size',
                value: _flagSize,
                min: 16,
                max: 48,
                onChanged: (v) => setState(() => _flagSize = v),
              ),
              _Slider(
                label: 'Item Height',
                value: _itemHeight,
                min: 40,
                max: 80,
                onChanged: (v) => setState(() => _itemHeight = v),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Radius
              const _Label('Radius'),
              const SizedBox(height: 8),
              _Slider(
                label: 'Sheet',
                value: _sheetRadius,
                min: 0,
                max: 40,
                onChanged: (v) => setState(() => _sheetRadius = v),
              ),
              _Slider(
                label: 'Dialog',
                value: _dialogRadius,
                min: 0,
                max: 40,
                onChanged: (v) => setState(() => _dialogRadius = v),
              ),
              _Slider(
                label: 'Dropdown',
                value: _dropdownRadius,
                min: 0,
                max: 24,
                onChanged: (v) => setState(() => _dropdownRadius = v),
              ),
              _Slider(
                label: 'Search Bar',
                value: _searchBarRadius,
                min: 0,
                max: 24,
                onChanged: (v) => setState(() => _searchBarRadius = v),
              ),
              _Slider(
                label: 'Flag',
                value: _flagRadius,
                min: 0,
                max: 14,
                onChanged: (v) => setState(() => _flagRadius = v),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Colors
              const _Label('Selected Color'),
              const SizedBox(height: 8),
              _ColorPicker(
                colors: _selectedColors,
                selectedIndex: _selectedColorIndex,
                onSelected: (i) => setState(() => _selectedColorIndex = i),
              ),
              const SizedBox(height: 16),
              const _Label('Indicator Color'),
              const SizedBox(height: 8),
              _ColorPicker(
                colors: _indicatorColors,
                selectedIndex: _indicatorColorIndex,
                onSelected: (i) => setState(() => _indicatorColorIndex = i),
              ),
              const SizedBox(height: 16),
              const _Label('Search Bar Color'),
              const SizedBox(height: 8),
              _ColorPicker(
                colors: _searchBarColors,
                selectedIndex: _searchBarColorIndex,
                onSelected: (i) => setState(() => _searchBarColorIndex = i),
              ),
              const SizedBox(height: 24),

              // Reset
              OutlinedButton(
                onPressed: () => setState(() {
                  _dark = false;
                  _sheetRadius = 28;
                  _dialogRadius = 20;
                  _dropdownRadius = 12;
                  _searchBarRadius = 12;
                  _flagRadius = 4;
                  _flagSize = 28;
                  _itemHeight = 56;
                  _showDividers = true;
                  _showHandle = true;
                  _selectedColorIndex = 0;
                  _indicatorColorIndex = 0;
                  _searchBarColorIndex = 0;
                }),
                child: const Text('Reset to Defaults'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600));
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text('${value.toInt()}',
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right),
        ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ColorPicker({
    required this.colors,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(colors.length, (i) {
        final isActive = i == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelected(i),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(
                        width: 3,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : Border.all(color: Colors.grey.shade300),
              ),
            ),
          ),
        );
      }),
    );
  }
}
