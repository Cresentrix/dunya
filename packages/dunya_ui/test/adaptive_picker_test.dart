import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
  group('Adaptive mode', () {
    group('adaptive: false (default)', () {
      testWidgets('renders Material trigger with arrow_drop_down',
          (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
          ),
        ));

        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_down), findsNothing);
      });

      testWidgets('uses InkWell for trigger', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
          ),
        ));

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('opens Material bottom sheet', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.byType(DraggableScrollableSheet), findsOneWidget);
        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('opens Material dialog', (tester) async {
        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dialog,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      });
    });

    group('adaptive: true on iOS', () {
      testWidgets('renders Cupertino trigger with chevron_down',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('opens Cupertino bottom sheet with xmark icon',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);
        expect(find.byIcon(Icons.close), findsNothing);
        expect(find.text('United Arab Emirates'), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('opens Cupertino dialog with CupertinoButton cancel',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dialog,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(CupertinoButton, 'Cancel'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('onSelected fires when country tapped', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        Country? selected;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (c) => selected = c,
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Egypt'));
        await tester.pumpAndSettle();

        expect(selected?.alpha2, 'EG');

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('dropdown uses Cupertino chevron icons', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            mode: DunyaPickerMode.dropdown,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('search bar renders CupertinoSearchTextField',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.byType(CupertinoSearchTextField), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('adaptive: true on Android', () {
      testWidgets('renders Material trigger even with adaptive: true',
          (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.chevron_down), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });

      testWidgets('opens Material bottom sheet on Android', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.xmark), findsNothing);

        debugDefaultTargetPlatformOverride = null;
      });
    });

    group('adaptive: true on macOS', () {
      testWidgets('renders Cupertino on macOS', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

        await tester.pumpWidget(_wrap(
          DunyaCountryPicker(
            countries: _countries,
            adaptive: true,
            onSelected: (_) {},
          ),
        ));

        expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);

        debugDefaultTargetPlatformOverride = null;
      });
    });
  });

  group('Adaptive DunyaDialCodeField', () {
    testWidgets('renders CupertinoTextField when adaptive on iOS',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          adaptive: true,
        ),
      ));

      expect(find.byType(CupertinoTextField), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders Cupertino chevron icon when adaptive', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          adaptive: true,
        ),
      ));

      expect(find.byIcon(CupertinoIcons.chevron_down), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('opens Cupertino bottom sheet on tap', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
          adaptive: true,
        ),
      ));

      await tester.tap(find.text('+--'));
      await tester.pumpAndSettle();

      expect(find.byIcon(CupertinoIcons.xmark), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('renders Material when adaptive: false on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(_wrap(
        DunyaDialCodeField(
          onCountryChanged: (_) {},
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('Cupertino shared widgets', () {
    testWidgets('CountrySearchBar renders CupertinoSearchTextField',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await tester.pumpWidget(_wrap(
        CountrySearchBar(
          onChanged: (_) {},
          useCupertino: true,
        ),
      ));

      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('CountrySearchBar renders Material TextField by default',
        (tester) async {
      await tester.pumpWidget(_wrap(
        CountrySearchBar(
          onChanged: (_) {},
        ),
      ));

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('CountryListTile uses checkmark icon when Cupertino',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final uae = _countries[0];

      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: uae,
          isSelected: true,
          onTap: () {},
          useCupertino: true,
        ),
      ));

      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('CountryListTile uses check icon when Material',
        (tester) async {
      final uae = _countries[0];

      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: uae,
          isSelected: true,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    });

    testWidgets('CountryListTile fires onTap in Cupertino mode',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      var tapped = false;
      final uae = _countries[0];

      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: uae,
          isSelected: false,
          onTap: () => tapped = true,
          useCupertino: true,
        ),
      ));

      await tester.tap(find.byType(CountryListTile));
      expect(tapped, isTrue);

      debugDefaultTargetPlatformOverride = null;
    });
  });
}
