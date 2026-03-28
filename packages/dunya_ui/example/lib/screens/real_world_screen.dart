import 'package:flutter/material.dart';
import 'package:dunya_ui/dunya_ui.dart';

/// Real-world form scenario: "Public Phone" field matching the design spec.
class RealWorldScreen extends StatefulWidget {
  const RealWorldScreen({super.key});

  @override
  State<RealWorldScreen> createState() => _RealWorldScreenState();
}

class _RealWorldScreenState extends State<RealWorldScreen> {
  Country? _phoneCountry;
  final _phoneController = TextEditingController();
  PhoneValidationResult? _validation1;

  Country? _phoneCountry2;
  final _phoneController2 = TextEditingController();
  PhoneValidationResult? _validation2;

  Country? _phoneCountry3;
  final _phoneController3 = TextEditingController();
  PhoneValidationResult? _validation3;

  @override
  void initState() {
    super.initState();
    _phoneCountry = CountryRepository.findByAlpha2('AE');
    _phoneCountry2 = CountryRepository.findByAlpha2('AE');
    _phoneCountry3 = CountryRepository.findByAlpha2('AE');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneController2.dispose();
    _phoneController3.dispose();
    super.dispose();
  }

  String _errorMessage(PhoneValidationError error) {
    switch (error) {
      case PhoneValidationError.empty:
        return 'Phone number is required';
      case PhoneValidationError.tooShort:
        return 'Phone number is too short';
      case PhoneValidationError.tooLong:
        return 'Phone number is too long';
      case PhoneValidationError.invalidCharacters:
        return 'Phone number contains invalid characters';
      case PhoneValidationError.unknownCountry:
        return 'Unknown country selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    const validColor = Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Real World')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ─── Field 1: Public Phone (phone icon + code) ───
          RichText(
            text: TextSpan(
              text: 'Public Phone',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: TextStyle(color: errorColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          DunyaDialCodeField(
            selectedCountry: _phoneCountry,
            onCountryChanged: (c) => setState(() {
              _phoneCountry = c;
              if (_phoneController.text.isNotEmpty) {
                _validation1 = PhoneValidator.validate(
                  _phoneController.text,
                  c.alpha2,
                );
              }
            }),
            controller: _phoneController,
            selectionLabel: true,
            glassEffect: true,
            adaptive: true,
            onFieldSubmitted: () {},
            numberHint: '4 XXX XXXX',
            enableValidation: true,
            onValidationChanged: (result) {
              setState(() => _validation1 = result);
            },
            favorites: const ['AE', 'KW', 'SA', 'QA', 'BH', 'OM'],
            triggerBuilder: (context, country, openPicker) {
              return GestureDetector(
                onTap: openPicker,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 12,
                    end: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.phone_outlined,
                        size: 22,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 10),
                      Text(
                        country?.dialCode ?? '+---',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          _ValidationStatus(
            result: _validation1,
            errorMessage: _errorMessage,
            errorColor: errorColor,
            validColor: validColor,
          ),
          const SizedBox(height: 32),

          // ─── Field 2: Phone Number (flag + code | number) ───
          Text(
            'Phone Number',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DunyaDialCodeField(
            selectedCountry: _phoneCountry2,
            onCountryChanged: (c) => setState(() {
              _phoneCountry2 = c;
              if (_phoneController2.text.isNotEmpty) {
                _validation2 = PhoneValidator.validate(
                  _phoneController2.text,
                  c.alpha2,
                );
              }
            }),
            controller: _phoneController2,
            triggerStyle: DunyaPickerTriggerStyle.flagAndCode,
            selectionLabel: false,
            adaptive: true,
            glassEffect: true,
            numberHint: 'XX XXX XXXX',
            enableValidation: true,
            onValidationChanged: (result) {
              setState(() => _validation2 = result);
            },
            favorites: const ['AE', 'KW', 'SA', 'QA', 'BH', 'OM'],
          ),
          _ValidationStatus(
            result: _validation2,
            errorMessage: _errorMessage,
            errorColor: errorColor,
            validColor: validColor,
          ),
          const SizedBox(height: 32),

          // ─── Field 3: Phone Number (filled trigger — flag + code + arrow) ───
          Text(
            'Phone Number',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          DunyaDialCodeField(
            selectedCountry: _phoneCountry3,
            onCountryChanged: (c) => setState(() {
              _phoneCountry3 = c;
              if (_phoneController3.text.isNotEmpty) {
                _validation3 = PhoneValidator.validate(
                  _phoneController3.text,
                  c.alpha2,
                );
              }
            }),
            controller: _phoneController3,
            selectionLabel: false,
            adaptive: true,
            glassEffect: true,
            numberHint: '50 123 4567',
            enableValidation: true,
            onValidationChanged: (result) {
              setState(() => _validation3 = result);
            },
            favorites: const ['AE', 'KW', 'SA', 'QA', 'BH', 'OM'],
            triggerBuilder: (context, country, openPicker) {
              final isDark =
                  Theme.of(context).brightness == Brightness.dark;
              final bgColor = isDark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFF2F2F7);
              final borderColor = isDark
                  ? const Color(0xFF3A3A3C)
                  : const Color(0xFFE5E5EA);
              return GestureDetector(
                onTap: openPicker,
                child: Container(
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    border: BorderDirectional(
                      end: BorderSide(color: borderColor),
                    ),
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(12),
                      bottomStart: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (country != null) ...[
                        FlagWidget(alpha2: country.alpha2, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          country.dialCode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ] else
                        Text(
                          '+---',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[500],
                          ),
                        ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          _ValidationStatus(
            result: _validation3,
            errorMessage: _errorMessage,
            errorColor: errorColor,
            validColor: validColor,
          ),
          const SizedBox(height: 32),

          // ─── Submit button ───
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final v1 = PhoneValidator.validate(
                  _phoneController.text,
                  _phoneCountry?.alpha2 ?? '',
                );
                final v2 = PhoneValidator.validate(
                  _phoneController2.text,
                  _phoneCountry2?.alpha2 ?? '',
                );
                final v3 = PhoneValidator.validate(
                  _phoneController3.text,
                  _phoneCountry3?.alpha2 ?? '',
                );
                setState(() {
                  _validation1 = v1;
                  _validation2 = v2;
                  _validation3 = v3;
                });

                if (v1.isValid && v2.isValid && v3.isValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('All fields valid!'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationStatus extends StatelessWidget {
  final PhoneValidationResult? result;
  final String Function(PhoneValidationError) errorMessage;
  final Color errorColor;
  final Color validColor;

  const _ValidationStatus({
    required this.result,
    required this.errorMessage,
    required this.errorColor,
    required this.validColor,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    final isValid = result!.isValid;
    final color = isValid ? validColor : errorColor;
    final icon = isValid ? Icons.check_circle : Icons.error_outline;
    final text = isValid
        ? 'Valid phone number'
        : errorMessage(result!.error!);

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
