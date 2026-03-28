import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/dunya_strings.dart';
import '../theme/dunya_picker_theme.dart';
import '../utils/platform_resolver.dart';
import '../widgets/shared/flag_widget.dart';
import 'dunya_country_picker.dart';
import 'presentations/bottom_sheet_presentation.dart';
import 'presentations/cupertino/cupertino_bottom_sheet_presentation.dart';
import 'presentations/cupertino/cupertino_dialog_presentation.dart';
import 'presentations/dialog_presentation.dart';

/// A combined country-code selector and phone number input field.
///
/// Set [adaptive] to `true` to use Cupertino styling on iOS/macOS.
/// Set [glassEffect] to `false` to disable the frosted blur (Cupertino only).
///
/// When [enableValidation] is `true`, the phone number is validated against
/// per-country length rules from [PhoneValidator]. The [onValidationChanged]
/// callback fires whenever the validation state changes.
class DunyaDialCodeField extends StatelessWidget {
  /// Builds input formatters: digit-only filter + per-country max length.
  List<TextInputFormatter> _buildInputFormatters() {
    return [
      // Allow ASCII digits, Eastern Arabic (٠-٩), Extended Arabic (۰-۹),
      // and common formatting characters (spaces, dashes, parens, dots).
      FilteringTextInputFormatter.allow(
        RegExp(r'[\d\u0660-\u0669\u06F0-\u06F9\s\-\(\)\.]'),
      ),
      if (selectedCountry != null)
        LengthLimitingTextInputFormatter(
          PhoneValidator.maxLengthFor(selectedCountry!.alpha2),
        ),
    ];
  }

  void _onPhoneChanged(String value) {
    if (onValidationChanged == null || selectedCountry == null) return;
    final result = PhoneValidator.validate(value, selectedCountry!.alpha2);
    onValidationChanged!(result);
  }

  /// The currently selected country shown in the dial code section.
  final Country? selectedCountry;

  /// Called when the user picks a different country.
  final ValueChanged<Country> onCountryChanged;

  /// Optional external controller for the phone number text field.
  final TextEditingController? controller;

  /// Which picker presentation to use when tapping the country section.
  final DunyaPickerMode pickerMode;

  /// Optional theme override.
  final DunyaPickerTheme? theme;

  /// Placeholder text in the phone number input.
  final String? numberHint;

  /// Controls which elements appear in the country trigger section.
  final DunyaPickerTriggerStyle triggerStyle;

  /// Completely replaces the default country section.
  final Widget Function(BuildContext, Country?, VoidCallback)? triggerBuilder;

  /// Whether to show a selection label below the field.
  final bool selectionLabel;

  /// Whether the picker search bar auto-focuses.
  final bool searchAutofocus;

  /// Use Cupertino styling on iOS/macOS when `true`.
  final bool adaptive;

  /// Enable frosted glass blur on Cupertino presentations.
  final bool glassEffect;

  /// When `true`, validates input against per-country length rules.
  final bool enableValidation;

  /// Fires on each keystroke with the validation result when enabled.
  final ValueChanged<PhoneValidationResult>? onValidationChanged;

  /// Called when the user presses done/submit on the keyboard.
  final VoidCallback? onFieldSubmitted;

  /// Alpha-2 codes of countries to pin at the top of the picker.
  final List<String> favorites;

  /// Alpha-2 codes of countries to hide from the picker.
  final List<String> exclude;

  const DunyaDialCodeField({
    required this.onCountryChanged,
    super.key,
    this.selectedCountry,
    this.controller,
    this.pickerMode = DunyaPickerMode.bottomSheet,
    this.theme,
    this.numberHint,
    this.triggerStyle = DunyaPickerTriggerStyle.all,
    this.triggerBuilder,
    this.selectionLabel = true,
    this.searchAutofocus = true,
    this.adaptive = false,
    this.glassEffect = true,
    this.enableValidation = false,
    this.onValidationChanged,
    this.onFieldSubmitted,
    this.favorites = const [],
    this.exclude = const [],
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final s = DunyaStrings.forLocale(locale);
    final t = DunyaPickerTheme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final cupertino = PlatformResolver.useCupertino(adaptive);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: t.resolveItemHeight(),
          decoration: BoxDecoration(
            borderRadius: t.resolveTriggerRadius(),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              triggerBuilder != null
                  ? triggerBuilder!(
                      context,
                      selectedCountry,
                      () => _openPicker(context),
                    )
                  : _buildCountrySection(
                      context, t, isDark, borderColor, cupertino),
              Expanded(
                child: cupertino
                    ? CupertinoTextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: _buildInputFormatters(),
                        placeholder: numberHint ?? s.phoneHint,
                        placeholderStyle: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8E93),
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFFEBEBF5)
                              : const Color(0xFF1C1C1E),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(),
                        onChanged: enableValidation ? _onPhoneChanged : null,
                        onEditingComplete: onFieldSubmitted,
                      )
                    : TextField(
                        controller: controller,
                        keyboardType: TextInputType.phone,
                        inputFormatters: _buildInputFormatters(),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? const Color(0xFFEBEBF5)
                              : const Color(0xFF1C1C1E),
                        ),
                        decoration: InputDecoration(
                          hintText: numberHint ?? s.phoneHint,
                          hintStyle: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8E8E93),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                        ),
                        onChanged: enableValidation ? _onPhoneChanged : null,
                        onEditingComplete: onFieldSubmitted,
                      ),
              ),
            ],
          ),
        ),
        if (selectionLabel && selectedCountry != null)
          _SelectionLabel(country: selectedCountry!),
      ],
    );
  }

  Widget _buildCountrySection(
    BuildContext context,
    DunyaPickerTheme t,
    bool isDark,
    Color borderColor,
    bool cupertino,
  ) {
    final textColor =
        isDark ? const Color(0xFFEBEBF5) : const Color(0xFF1C1C1E);
    final showFlag = triggerStyle == DunyaPickerTriggerStyle.flagOnly ||
        triggerStyle == DunyaPickerTriggerStyle.flagAndCode ||
        triggerStyle == DunyaPickerTriggerStyle.all;
    final showCode = triggerStyle == DunyaPickerTriggerStyle.codeOnly ||
        triggerStyle == DunyaPickerTriggerStyle.flagAndCode ||
        triggerStyle == DunyaPickerTriggerStyle.codeAndArrow ||
        triggerStyle == DunyaPickerTriggerStyle.all;
    final showArrow = triggerStyle == DunyaPickerTriggerStyle.codeAndArrow ||
        triggerStyle == DunyaPickerTriggerStyle.all ||
        triggerStyle == DunyaPickerTriggerStyle.codeOnly;

    final content = Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedCountry != null) ...[
            if (showFlag) ...[
              FlagWidget(
                alpha2: selectedCountry!.alpha2,
                size: 24,
              ),
              if (showCode || showArrow) const SizedBox(width: 6),
            ],
            if (showCode)
              Text(
                selectedCountry!.dialCode,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
          ] else
            const Text(
              '+--',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8E8E93),
              ),
            ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            Icon(
              cupertino ? CupertinoIcons.chevron_down : Icons.arrow_drop_down,
              size: cupertino ? 14 : 18,
              color: const Color(0xFF8E8E93),
            ),
          ],
        ],
      ),
    );

    if (cupertino) {
      return GestureDetector(
        onTap: () => _openPicker(context),
        child: content,
      );
    }

    return InkWell(
      onTap: () => _openPicker(context),
      child: content,
    );
  }

  List<Country> get _filteredCountries {
    if (exclude.isEmpty) return CountryRepository.all;
    final codes = exclude.map((c) => c.toUpperCase()).toSet();
    return CountryRepository.all
        .where((c) => !codes.contains(c.alpha2))
        .toList(growable: false);
  }

  Future<void> _openPicker(BuildContext context) async {
    final cupertino = PlatformResolver.useCupertino(adaptive);
    final countries = _filteredCountries;
    final Country? result;

    switch (pickerMode) {
      case DunyaPickerMode.bottomSheet:
        if (cupertino) {
          result = await CupertinoBottomSheetPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: selectedCountry,
            searchAutofocus: searchAutofocus,
            glassEffect: glassEffect,
            favorites: favorites,
          );
        } else {
          result = await BottomSheetPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: selectedCountry,
            searchAutofocus: searchAutofocus,
            favorites: favorites,
          );
        }
      case DunyaPickerMode.dialog:
        if (cupertino) {
          result = await CupertinoDialogPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: selectedCountry,
            searchAutofocus: searchAutofocus,
            glassEffect: glassEffect,
            favorites: favorites,
          );
        } else {
          result = await DialogPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: selectedCountry,
            searchAutofocus: searchAutofocus,
            favorites: favorites,
          );
        }
      case DunyaPickerMode.dropdown:
        return;
    }

    if (result != null) {
      onCountryChanged(result);
    }
  }
}

class _SelectionLabel extends StatelessWidget {
  final Country country;
  const _SelectionLabel({required this.country});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final displayName =
        CountryLocalizations.nameOf(country.alpha2, locale) ?? country.name;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6, start: 2),
      child: Row(
        children: [
          FlagWidget(alpha2: country.alpha2, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$displayName  ${country.dialCode}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
