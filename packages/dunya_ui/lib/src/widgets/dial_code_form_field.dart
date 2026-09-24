import 'package:dunya/dunya.dart';
import 'package:flutter/material.dart';

import '../theme/dunya_picker_theme.dart';
import 'dial_code_field.dart';
import 'dunya_country_picker.dart';

/// A [FormField] wrapper around [DunyaDialCodeField].
///
/// Integrates with Flutter's [Form] system so that [validator], [onSaved],
/// and [autovalidateMode] work as expected. The form field value is a
/// [PhoneNumber] parsed from the current country and text input.
///
/// ```dart
/// DunyaDialCodeFormField(
///   onCountryChanged: (c) => setState(() => _country = c),
///   validator: (phone) {
///     if (phone == null || !phone.isValid) return 'Invalid phone';
///     return null;
///   },
///   onSaved: (phone) => _savedPhone = phone!.e164,
/// )
/// ```
class DunyaDialCodeFormField extends StatefulWidget {
  /// The currently selected country.
  final Country? selectedCountry;

  /// Called when the user picks a different country.
  final ValueChanged<Country> onCountryChanged;

  /// Optional external controller for the phone number input.
  final TextEditingController? controller;

  /// Which picker presentation to use.
  final DunyaPickerMode pickerMode;

  /// Placeholder text in the phone number input.
  final String? numberHint;

  /// Controls which elements appear in the country trigger.
  final DunyaPickerTriggerStyle triggerStyle;

  /// Completely replaces the default country trigger section.
  final Widget Function(BuildContext, Country?, VoidCallback)? triggerBuilder;

  /// Whether to show a selection label below the field.
  final bool selectionLabel;

  /// Whether the picker search bar auto-focuses.
  final bool searchAutofocus;

  /// Use Cupertino styling on iOS/macOS.
  final bool adaptive;

  /// Enable frosted glass blur on Cupertino presentations.
  final bool glassEffect;

  /// Alpha-2 codes of countries to pin at the top of the picker.
  final List<String> favorites;

  /// Alpha-2 codes of countries to hide from the picker.
  final List<String> exclude;

  /// When `true`, the picker cannot be opened and the phone input is
  /// read-only. The field appears visually disabled.
  final bool readOnly;

  /// Validates the parsed [PhoneNumber]. Return `null` for valid, or an
  /// error string to display below the field.
  final String? Function(PhoneNumber?)? validator;

  /// Called with the parsed [PhoneNumber] when the form is saved.
  final ValueChanged<PhoneNumber?>? onSaved;

  /// When to auto-validate (defaults to [AutovalidateMode.disabled]).
  final AutovalidateMode autovalidateMode;

  /// Called when the user presses done/submit on the keyboard.
  final VoidCallback? onFieldSubmitted;

  /// Fires with the raw phone number input on every change.
  final ValueChanged<String>? onChanged;

  /// Optional theme override.
  final DunyaPickerTheme? theme;

  /// Optional focus node for the phone number input.
  final FocusNode? focusNode;

  /// The keyboard action button, e.g. [TextInputAction.next].
  final TextInputAction? textInputAction;

  /// Autofill hints for the phone number input.
  final Iterable<String>? autofillHints;

  /// Creates a dial code form field.
  const DunyaDialCodeFormField({
    required this.onCountryChanged,
    super.key,
    this.selectedCountry,
    this.controller,
    this.pickerMode = DunyaPickerMode.bottomSheet,
    this.numberHint,
    this.triggerStyle = DunyaPickerTriggerStyle.all,
    this.triggerBuilder,
    this.selectionLabel = true,
    this.searchAutofocus = true,
    this.adaptive = false,
    this.glassEffect = true,
    this.favorites = const [],
    this.exclude = const [],
    this.readOnly = false,
    this.validator,
    this.onSaved,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onFieldSubmitted,
    this.onChanged,
    this.theme,
    this.focusNode,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.telephoneNumberNational],
  });

  @override
  State<DunyaDialCodeFormField> createState() => _DunyaDialCodeFormFieldState();
}

class _DunyaDialCodeFormFieldState extends State<DunyaDialCodeFormField> {
  final _formFieldKey = GlobalKey<FormFieldState<PhoneNumber>>();
  TextEditingController? _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _effectiveController.addListener(_onInputChanged);
  }

  @override
  void didUpdateWidget(DunyaDialCodeFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      // Move the listener to whichever controller is now in use.
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_onInputChanged);
      if (widget.controller == null) {
        _internalController ??= TextEditingController(
          text: oldWidget.controller?.text,
        );
      } else {
        _internalController?.dispose();
        _internalController = null;
      }
      _effectiveController.addListener(_onInputChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateFormValue();
      });
    }
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      // Country changed — re-parse and update form field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateFormValue();
      });
    }
  }

  void _onInputChanged() {
    _updateFormValue();
  }

  PhoneNumber? _parse() {
    final country = widget.selectedCountry;
    final text = _effectiveController.text;
    if (country == null || text.isEmpty) return null;
    return PhoneNumber.parse(country.dialCode, text, country.alpha2);
  }

  void _updateFormValue() {
    _formFieldKey.currentState?.didChange(_parse());
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_onInputChanged);
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<PhoneNumber>(
      key: _formFieldKey,
      // Text already in the controller counts from the start, so a
      // pre-filled number passes validation without being edited.
      initialValue: _parse(),
      validator: widget.validator,
      onSaved: widget.onSaved,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<PhoneNumber> field) {
        return DunyaDialCodeField(
          selectedCountry: widget.selectedCountry,
          onCountryChanged: widget.onCountryChanged,
          controller: _effectiveController,
          pickerMode: widget.pickerMode,
          theme: widget.theme,
          numberHint: widget.numberHint,
          triggerStyle: widget.triggerStyle,
          triggerBuilder: widget.triggerBuilder,
          selectionLabel: widget.selectionLabel,
          searchAutofocus: widget.searchAutofocus,
          adaptive: widget.adaptive,
          glassEffect: widget.glassEffect,
          onChanged: widget.onChanged,
          errorText: field.errorText,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          favorites: widget.favorites,
          exclude: widget.exclude,
          readOnly: widget.readOnly,
        );
      },
    );
  }
}
