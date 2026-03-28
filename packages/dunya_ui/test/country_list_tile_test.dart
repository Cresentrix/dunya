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

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      extensions: const [DunyaPickerTheme()],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('CountryListTile', () {
    testWidgets('displays flag and country name', (tester) async {
      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: _uae,
          isSelected: false,
          onTap: () {},
        ),
      ));

      expect(find.text('United Arab Emirates'), findsOneWidget);
      expect(find.text('AE'), findsOneWidget);
      expect(find.byType(FlagWidget), findsOneWidget);
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: _uae,
          isSelected: false,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(CountryListTile));
      expect(tapped, isTrue);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: _uae,
          isSelected: true,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('hides check icon when not selected', (tester) async {
      await tester.pumpWidget(_wrap(
        CountryListTile(
          country: _uae,
          isSelected: false,
          onTap: () {},
        ),
      ));

      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('applies selected background color from theme', (tester) async {
      const customTheme = DunyaPickerTheme(
        selectedColor: Color(0xFFFF0000),
      );

      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(
          extensions: const [customTheme],
        ),
        home: Scaffold(
          body: CountryListTile(
            country: _uae,
            isSelected: true,
            onTap: () {},
          ),
        ),
      ));

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(CountryListTile),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.color;
      expect(decoration, const Color(0xFFFF0000));
    });
  });
}
