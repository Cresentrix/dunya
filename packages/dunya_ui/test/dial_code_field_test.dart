import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dunya_ui/dunya_ui.dart';

const _uae = Country(
  name: 'United Arab Emirates',
  nativeName: 'الإمارات',
  alpha2: 'AE',
  alpha3: 'ARE',
  numeric: 784,
  region: 'Asia',
  subregion: 'Western Asia',
  dialCode: '+971',
  flagCode: 'ae',
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [DunyaPickerTheme()],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DunyaDialCodeField', () {
    testWidgets('renders with no selected country', (tester) async {
      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
        ),
      ));

      expect(find.text('+--'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows flag and dial code when country selected',
        (tester) async {
      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          selectedCountry: _uae,
          onCountryChanged: (_) {},
        ),
      ));

      // One in the country section, one in the selection label
      expect(find.text('+971'), findsNWidgets(2));
      // One flag in the trigger, one in the selection label
      expect(find.byType(FlagWidget), findsNWidgets(2));
    });

    testWidgets('tap opens picker', (tester) async {
      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
        ),
      ));

      // Tap the country section (the +-- text area)
      await tester.tap(find.text('+--'));
      await tester.pumpAndSettle();

      // Bottom sheet should open with country list
      expect(find.text('Select Country'), findsOneWidget);
    });

    testWidgets('onCountryChanged fires after picker selection',
        (tester) async {
      Country? changed;

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (c) => changed = c,
        ),
      ));

      await tester.tap(find.text('+--'));
      await tester.pumpAndSettle();

      // Tap first country in the list
      await tester.tap(find.byType(CountryListTile).first);
      await tester.pumpAndSettle();

      expect(changed, isNotNull);
    });

    testWidgets('displays number hint', (tester) async {
      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          numberHint: '50 123 4567',
        ),
      ));

      expect(find.text('50 123 4567'), findsOneWidget);
    });

    testWidgets('uses dialog picker mode', (tester) async {
      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          pickerMode: DunyaPickerMode.dialog,
        ),
      ));

      await tester.tap(find.text('+--'));
      await tester.pumpAndSettle();

      // Dialog has a Cancel button
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('accepts text input in number field', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          controller: controller,
        ),
      ));

      await tester.enterText(find.byType(TextField), '501234567');
      expect(controller.text, '501234567');
    });
  });
}
