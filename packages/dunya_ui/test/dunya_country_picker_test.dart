import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dunya_ui/dunya_ui.dart';

const _countries = [
  Country(
    name: 'United Arab Emirates',
    nativeName: 'الإمارات',
    alpha2: 'AE',
    alpha3: 'ARE',
    numeric: 784,
    region: 'Asia',
    subregion: 'Western Asia',
    dialCode: '+971',
    flagCode: 'ae',
  ),
  Country(
    name: 'United States',
    nativeName: 'United States',
    alpha2: 'US',
    alpha3: 'USA',
    numeric: 840,
    region: 'Americas',
    subregion: 'North America',
    dialCode: '+1',
    flagCode: 'us',
  ),
  Country(
    name: 'Egypt',
    nativeName: 'مصر',
    alpha2: 'EG',
    alpha3: 'EGY',
    numeric: 818,
    region: 'Africa',
    subregion: 'Northern Africa',
    dialCode: '+20',
    flagCode: 'eg',
  ),
];

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [DunyaPickerTheme()],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('DunyaCountryPicker', () {
    group('bottomSheet mode', () {
      testWidgets('renders trigger button', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
          ),
        ));

        expect(find.text('Select Country'), findsOneWidget);
      });

      testWidgets('opens bottom sheet on tap', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        // Bottom sheet shows country list
        expect(find.text('United Arab Emirates'), findsOneWidget);
        expect(find.text('United States'), findsOneWidget);
        expect(find.text('Egypt'), findsOneWidget);
      });

      testWidgets('onSelected fires when country tapped', (tester) async {
        Country? selected;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (c) => selected = c,
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Egypt'));
        await tester.pumpAndSettle();

        expect(selected?.alpha2, 'EG');
      });

      testWidgets('shows selected country name in trigger', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            selectedCountry: _countries[0],
            onSelected: (_) {},
          ),
        ));

        expect(find.text('United Arab Emirates'), findsOneWidget);
      });
    });

    group('dialog mode', () {
      testWidgets('opens dialog on tap', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dialog,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.text('United Arab Emirates'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('cancel closes dialog without selecting', (tester) async {
        Country? selected;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dialog,
            onSelected: (c) => selected = c,
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(selected, isNull);
      });
    });

    group('dropdown mode', () {
      testWidgets('renders inline trigger', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dropdown,
            onSelected: (_) {},
          ),
        ));

        expect(find.text('Select Country'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });
    });

    group('emptyBuilder', () {
      testWidgets('shows emptyBuilder when search has no results',
          (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
            emptyBuilder: (_) => const Text('Nothing here'),
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        // Type a query that matches nothing
        await tester.enterText(find.byType(TextField), 'zzzzzz');
        await tester.pumpAndSettle();

        expect(find.text('Nothing here'), findsOneWidget);
      });
    });

    group('theme', () {
      testWidgets('applies custom theme', (tester) async {
        const customTheme = DunyaPickerTheme(
          itemHeight: 72,
        );

        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(
            extensions: const [customTheme],
          ),
          home: Scaffold(
            body: DunyaCountryPicker(
              countries: _countries,
              onSelected: (_) {},
            ),
          ),
        ));

        // Trigger button should use custom item height
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(DunyaCountryPicker),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(container.constraints?.maxHeight, 72);
      });
    });
  });
}
