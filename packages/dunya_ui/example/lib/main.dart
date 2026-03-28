import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dunya_ui/dunya_ui.dart';
import 'package:dunya/l10n.dart';

void main() {
  // Register Arabic country names for localized search & display
  CountryLocalizations.register('ar', kCountryNamesAr);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'en'
          ? const Locale('ar')
          : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF7F77DD),
        useMaterial3: true,
        extensions: const [DunyaPickerTheme()],
      ),
      home: CountryPickerDemo(
        isArabic: _locale.languageCode == 'ar',
        onToggleLocale: _toggleLocale,
      ),
    );
  }
}

class CountryPickerDemo extends StatefulWidget {
  const CountryPickerDemo({
    super.key,
    required this.isArabic,
    required this.onToggleLocale,
  });

  final bool isArabic;
  final VoidCallback onToggleLocale;

  @override
  State<CountryPickerDemo> createState() => _CountryPickerDemoState();
}

class _CountryPickerDemoState extends State<CountryPickerDemo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  Country? _selectedCountry;
  Country? _phoneCountry;
  bool _phoneValid = false;
  String? _phoneError;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final isAr = widget.isArabic;
    setState(() {
      _submitted = true;
      if (_phoneController.text.isEmpty) {
        _phoneError =
            isAr ? 'رقم الهاتف مطلوب' : 'Phone number is required';
      } else if (!_phoneValid) {
        _phoneError =
            isAr ? 'رقم الهاتف غير صالح' : 'Invalid phone number';
      } else {
        _phoneError = null;
      }
    });

    final formValid = _formKey.currentState!.validate();
    final countryValid = _selectedCountry != null;

    if (formValid && countryValid && _phoneError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submitted: ${_nameController.text}, '
            '${_selectedCountry!.name}, '
            '+${_phoneCountry?.dialCode ?? ''} ${_phoneController.text}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isAr = widget.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'مثال دنيا' : 'Dunya Example'),
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLocale,
            icon: const Icon(Icons.language),
            label: Text(isAr ? 'EN' : 'عربي'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'التسجيل' : 'Registration',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // --- Name Field ---
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAr ? 'الاسم الكامل' : 'Full Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isAr ? 'الاسم مطلوب' : 'Name is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // --- Country Picker ---
              Text(
                isAr ? 'الدولة' : 'Country',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DunyaCountryPicker(
                countries: CountryRepository.all,
                selectedCountry: _selectedCountry,
                onSelected: (c) => setState(() => _selectedCountry = c),
                favorites: const ['KW', 'US', 'GB'],
              ),
              if (_submitted && _selectedCountry == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    isAr ? 'يرجى اختيار الدولة' : 'Please select a country',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),

              const SizedBox(height: 24),

              // --- Phone Input ---
              Text(
                isAr ? 'رقم الهاتف' : 'Phone Number',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DunyaDialCodeField(
                selectedCountry: _phoneCountry,
                onCountryChanged: (c) => setState(() => _phoneCountry = c),
                controller: _phoneController,
                enableValidation: true,
                onValidationChanged: (result) {
                  setState(() {
                    _phoneValid = result.isValid;
                    if (_submitted) {
                      _phoneError = result.isValid ? null : (isAr
                          ? 'رقم الهاتف غير صالح'
                          : 'Invalid phone number');
                    }
                  });
                },
              ),
              if (_submitted && _phoneError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    _phoneError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.error),
                  ),
                ),

              const SizedBox(height: 32),

              // --- Submit Button ---
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(isAr ? 'إرسال' : 'Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
