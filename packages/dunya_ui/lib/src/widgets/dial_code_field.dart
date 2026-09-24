import 'package:dunya/dunya.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/dunya_strings.dart';
import '../theme/dunya_picker_theme.dart';
import '../utils/picker_theme_scope.dart';
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
/// [onChanged] fires with the raw input on every keystroke. When
/// [enableValidation] is `true`, the number is also validated against
/// per-country length rules from [PhoneValidator], and
/// [onValidationChanged] fires on each keystroke and country change.
///
/// Colors, text styles and height come from [DunyaPickerTheme]
/// (`fieldBorderColor`, `fieldTextStyle`, `fieldHeight`, `errorColor`, …).
class DunyaDialCodeField extends StatefulWidget {
  /// The currently selected country shown in the dial code section.
  final Country? selectedCountry;

  /// Called when the user picks a different country.
  final ValueChanged<Country> onCountryChanged;

  /// Optional external controller for the phone number text field.
  final TextEditingController? controller;

  /// Which picker presentation to use when tapping the country section.
  ///
  /// [DunyaPickerMode.dropdown] needs a full-width trigger, so this field
  /// opens a bottom sheet instead.
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

  /// Fires with the validation result on each keystroke and country change
  /// when [enableValidation] is `true`.
  final ValueChanged<PhoneValidationResult>? onValidationChanged;

  /// Fires with the raw phone number input on every change.
  final ValueChanged<String>? onChanged;

  /// Error message shown below the field. The border also switches to
  /// the theme's `errorColor`. `null` shows no error.
  final String? errorText;

  /// Called when the user presses done/submit on the keyboard.
  final VoidCallback? onFieldSubmitted;

  /// Optional focus node for the phone number input.
  final FocusNode? focusNode;

  /// The keyboard action button, e.g. [TextInputAction.next].
  final TextInputAction? textInputAction;

  /// Autofill hints for the phone number input.
  final Iterable<String>? autofillHints;

  /// Alpha-2 codes of countries to pin at the top of the picker.
  final List<String> favorites;

  /// Alpha-2 codes of countries to hide from the picker.
  final List<String> exclude;

  /// When `true`, the picker cannot be opened and the phone input is
  /// read-only. The field appears visually disabled.
  final bool readOnly;

  /// Creates a dial code field.
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
    this.onChanged,
    this.errorText,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.telephoneNumberNational],
    this.favorites = const [],
    this.exclude = const [],
    this.readOnly = false,
  });

  @override
  State<DunyaDialCodeField> createState() => _DunyaDialCodeFieldState();
}

class _DunyaDialCodeFieldState extends State<DunyaDialCodeField> {
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void didUpdateWidget(DunyaDialCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      // The same digits may be valid for one country and not another.
      // Deferred: the callback usually calls setState on the parent,
      // which is still building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _validate(_controller.text);
      });
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  /// Builds input formatters: dial code removal on paste, digit-only
  /// filter and per-country max length.
  List<TextInputFormatter> _buildInputFormatters() {
    final country = widget.selectedCountry;
    return [
      // Runs first, while a pasted "+" is still there.
      if (country != null) _PastedDialCodeFormatter(country),
      // Allow ASCII digits, Eastern Arabic (٠-٩), Extended Arabic (۰-۹),
      // and common formatting characters (spaces, dashes, parens, dots).
      FilteringTextInputFormatter.allow(
        RegExp(r'[\d٠-٩۰-۹\s\-\(\)\.]'),
      ),
      if (country != null)
        _DigitLimitFormatter(PhoneValidator.maxLengthFor(country.alpha2)),
    ];
  }

  void _onPhoneChanged(String value) {
    widget.onChanged?.call(value);
    _validate(value);
  }

  void _validate(String value) {
    final country = widget.selectedCountry;
    if (!widget.enableValidation ||
        widget.onValidationChanged == null ||
        country == null) {
      return;
    }
    widget.onValidationChanged!(PhoneValidator.validate(value, country.alpha2));
  }

  @override
  Widget build(BuildContext context) {
    final content = Builder(builder: _buildContent);
    final theme = widget.theme;
    return theme == null ? content : withPickerTheme(context, theme, content);
  }

  /// [context] sits below the [widget.theme] override, so the picker it
  /// opens uses that theme too.
  Widget _buildContent(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final s = DunyaStrings.forLocale(locale);
    final t = DunyaPickerTheme.of(context);
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? t.resolveErrorColor(context)
        : t.resolveFieldBorderColor(context);
    final dividerColor = t.resolveFieldBorderColor(context);
    final textStyle = t.resolveFieldTextStyle(context);
    final hintStyle = t.resolveFieldHintStyle();
    final hint = widget.numberHint ?? s.phoneHint;
    final cupertino = PlatformResolver.useCupertino(widget.adaptive);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: t.resolveFieldHeight(),
          decoration: BoxDecoration(
            color: t.resolveFieldBackgroundColor(),
            borderRadius: t.resolveTriggerRadius(),
            border: Border.all(color: borderColor),
          ),
          child: Opacity(
            opacity: widget.readOnly ? 0.5 : 1.0,
            child: Row(
              children: [
                widget.triggerBuilder != null
                    ? widget.triggerBuilder!(
                        context,
                        widget.selectedCountry,
                        widget.readOnly ? () {} : () => _openPicker(context),
                      )
                    : _buildCountrySection(
                        context, textStyle, dividerColor, cupertino),
                Expanded(
                  child: cupertino
                      ? CupertinoTextField(
                          controller: _controller,
                          focusNode: widget.focusNode,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.phone,
                          textInputAction: widget.textInputAction,
                          autofillHints: widget.autofillHints,
                          inputFormatters: _buildInputFormatters(),
                          placeholder: hint,
                          placeholderStyle: hintStyle,
                          style: textStyle,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: const BoxDecoration(),
                          onChanged: _onPhoneChanged,
                          onEditingComplete: widget.onFieldSubmitted,
                        )
                      : TextField(
                          controller: _controller,
                          focusNode: widget.focusNode,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.phone,
                          textInputAction: widget.textInputAction,
                          autofillHints: widget.autofillHints,
                          inputFormatters: _buildInputFormatters(),
                          style: textStyle,
                          decoration: InputDecoration(
                            hintText: hint,
                            hintStyle: hintStyle,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            border: InputBorder.none,
                          ),
                          onChanged: _onPhoneChanged,
                          onEditingComplete: widget.onFieldSubmitted,
                        ),
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 6, start: 2),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                fontSize: 12,
                color: t.resolveErrorColor(context),
              ),
            ),
          ),
        if (widget.selectionLabel && widget.selectedCountry != null)
          _SelectionLabel(country: widget.selectedCountry!),
      ],
    );
  }

  Widget _buildCountrySection(
    BuildContext context,
    TextStyle textStyle,
    Color dividerColor,
    bool cupertino,
  ) {
    final triggerStyle = widget.triggerStyle;
    final selectedCountry = widget.selectedCountry;
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
    final codeStyle = textStyle.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    final content = Container(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: dividerColor)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedCountry != null) ...[
            if (showFlag) ...[
              FlagWidget(
                alpha2: selectedCountry.alpha2,
                size: 24,
              ),
              if (showCode || showArrow) const SizedBox(width: 6),
            ],
            if (showCode)
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(selectedCountry.dialCode, style: codeStyle),
              ),
          ] else
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '+--',
                style: codeStyle.copyWith(color: const Color(0xFF8E8E93)),
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

    final onTap = widget.readOnly ? null : () => _openPicker(context);
    if (cupertino) {
      return GestureDetector(onTap: onTap, child: content);
    }
    return InkWell(onTap: onTap, child: content);
  }

  List<Country> get _filteredCountries {
    if (widget.exclude.isEmpty) return CountryRepository.all;
    final codes = widget.exclude.map((c) => c.toUpperCase()).toSet();
    return CountryRepository.all
        .where((c) => !codes.contains(c.alpha2))
        .toList(growable: false);
  }

  Future<void> _openPicker(BuildContext context) async {
    final cupertino = PlatformResolver.useCupertino(widget.adaptive);
    final countries = _filteredCountries;
    final Country? result;

    switch (widget.pickerMode) {
      case DunyaPickerMode.dialog:
        if (cupertino) {
          result = await CupertinoDialogPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: widget.selectedCountry,
            searchAutofocus: widget.searchAutofocus,
            glassEffect: widget.glassEffect,
            favorites: widget.favorites,
          );
        } else {
          result = await DialogPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: widget.selectedCountry,
            searchAutofocus: widget.searchAutofocus,
            favorites: widget.favorites,
          );
        }
      case DunyaPickerMode.bottomSheet:
      case DunyaPickerMode.dropdown:
        if (cupertino) {
          result = await CupertinoBottomSheetPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: widget.selectedCountry,
            searchAutofocus: widget.searchAutofocus,
            glassEffect: widget.glassEffect,
            favorites: widget.favorites,
          );
        } else {
          result = await BottomSheetPresentation.show(
            context: context,
            countries: countries,
            selectedCountry: widget.selectedCountry,
            searchAutofocus: widget.searchAutofocus,
            favorites: widget.favorites,
          );
        }
    }

    if (result != null && mounted) {
      widget.onCountryChanged(result);
    }
  }
}

/// Removes the selected country's dial code from a pasted number, so
/// "+965 5012 3456" pasted into the Kuwait field becomes "5012 3456"
/// instead of being cut to "965 5012".
///
/// Only multi-character inserts (paste, autofill) are changed. A code
/// without "+" or "00" is only removed when the number is too long to be
/// national and fits once it's gone, since a national number can start
/// with the same digits.
class _PastedDialCodeFormatter extends TextInputFormatter {
  final String dialDigits;
  final int maxDigits;

  _PastedDialCodeFormatter(Country country)
      : dialDigits = country.dialCode.replaceAll('+', ''),
        maxDigits = PhoneValidator.maxLengthFor(country.alpha2);

  static final _leadingFormatting = RegExp(r'^[\s\-\.]+');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length - oldValue.text.length < 2) return newValue;

    var national = _afterDialCode(newValue.text, prefixed: true);
    if (national == null &&
        PhoneNumber.stripFormatting(newValue.text).length > maxDigits) {
      national = _afterDialCode(newValue.text, prefixed: false);
      if (national != null &&
          PhoneNumber.stripFormatting(national).length > maxDigits) {
        national = null;
      }
    }
    if (national == null) return newValue;
    return TextEditingValue(
      text: national,
      selection: TextSelection.collapsed(offset: national.length),
    );
  }

  /// The text after a leading dial code, or `null` if it doesn't start
  /// with one. With [prefixed], the code must follow "+" or "00".
  String? _afterDialCode(String text, {required bool prefixed}) {
    var rest = text.trimLeft();
    if (prefixed) {
      if (rest.startsWith('+')) {
        rest = rest.substring(1);
      } else if (rest.startsWith('00')) {
        rest = rest.substring(2);
      } else {
        return null;
      }
      rest = rest.trimLeft();
    }
    if (!rest.startsWith(dialDigits)) return null;
    return rest
        .substring(dialDigits.length)
        .replaceFirst(_leadingFormatting, '');
  }
}

/// Caps the number of digits, ignoring spaces, dashes, parens and dots,
/// so formatted input like "50 123 456" isn't cut off early.
class _DigitLimitFormatter extends TextInputFormatter {
  final int maxDigits;

  _DigitLimitFormatter(this.maxDigits);

  static final _formatting = RegExp(r'[\s\-\(\)\.]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = PhoneNumber.stripFormatting(newValue.text).length;
    if (digits <= maxDigits) return newValue;
    // Text can already be over the limit after switching to a country
    // with shorter numbers. Deleting from it must still work.
    if (digits <= PhoneNumber.stripFormatting(oldValue.text).length) {
      return newValue;
    }
    // Too many digits, e.g. a pasted number: keep the first maxDigits.
    final text = newValue.text;
    var count = 0;
    var end = 0;
    while (count < maxDigits) {
      if (!_formatting.hasMatch(text[end])) count++;
      end++;
    }
    final truncated = text.substring(0, end);
    final offset = newValue.selection.extentOffset.clamp(0, truncated.length);
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

class _SelectionLabel extends StatelessWidget {
  final Country country;
  const _SelectionLabel({required this.country});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
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
              displayName,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              country.dialCode,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF8E8E93)
                    : const Color(0xFF636366),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
