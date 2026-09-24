import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dunya_ui/dunya_ui.dart';
import 'package:dunya_ui/src/widgets/shared/country_list_view.dart';

final _kw = CountryRepository.findByAlpha2('KW')!;
final _ae = CountryRepository.findByAlpha2('AE')!;
const _red = Color(0xFFFF0000);

Widget _wrap(Widget child, {GlobalKey<NavigatorState>? navigatorKey}) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    home: Scaffold(body: child),
  );
}

/// The border color of the [DunyaDialCodeField] input box.
Color _fieldBorderColor(WidgetTester tester) {
  final container = tester.widget<Container>(
    find
        .descendant(
          of: find.byType(DunyaDialCodeField),
          matching: find.byType(Container),
        )
        .first,
  );
  final border = (container.decoration! as BoxDecoration).border! as Border;
  return border.top.color;
}

void main() {
  group('DunyaDialCodeField', () {
    testWidgets('onChanged fires without validation enabled', (tester) async {
      String? value;
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        selectedCountry: _kw,
        onCountryChanged: (_) {},
        onChanged: (v) => value = v,
      )));

      await tester.enterText(find.byType(TextField), '50123456');
      expect(value, '50123456');
    });

    testWidgets('errorText is shown and colors the border', (tester) async {
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        selectedCountry: _kw,
        onCountryChanged: (_) {},
        errorText: 'Invalid phone',
        theme: const DunyaPickerTheme(errorColor: _red),
      )));

      expect(find.text('Invalid phone'), findsOneWidget);
      expect(_fieldBorderColor(tester), _red);
    });

    testWidgets('theme parameter styles the field', (tester) async {
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        selectedCountry: _kw,
        onCountryChanged: (_) {},
        theme: const DunyaPickerTheme(fieldBorderColor: _red),
      )));

      expect(_fieldBorderColor(tester), _red);
    });

    testWidgets('theme parameter reaches the picker sheet', (tester) async {
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        selectedCountry: _kw,
        onCountryChanged: (_) {},
        theme: const DunyaPickerTheme(fieldBorderColor: _red),
      )));

      await tester.tap(find.text('+965').first);
      await tester.pumpAndSettle();

      final listContext = tester.element(find.byType(CountryListView));
      expect(DunyaPickerTheme.of(listContext).fieldBorderColor, _red);
    });

    testWidgets('re-validates when the country changes', (tester) async {
      final results = <bool>[];
      final controller = TextEditingController(text: '50123456');
      Widget build(Country country) => _wrap(DunyaDialCodeField(
            selectedCountry: country,
            onCountryChanged: (_) {},
            controller: controller,
            enableValidation: true,
            onValidationChanged: (r) => results.add(r.isValid),
          ));

      await tester.pumpWidget(build(_kw));
      await tester.pumpWidget(build(_ae));
      await tester.pump();

      // 8 digits is a valid Kuwaiti number but too short for the UAE.
      expect(results, [false]);
    });

    testWidgets('digit limit ignores formatting characters', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        selectedCountry: _kw,
        onCountryChanged: (_) {},
        controller: controller,
      )));

      await tester.enterText(find.byType(TextField), '5012 3456');
      expect(controller.text, '5012 3456');

      await tester.enterText(find.byType(TextField), '5012 34567');
      expect(controller.text, '5012 3456');
    });

    testWidgets('dropdown mode opens the bottom sheet', (tester) async {
      await tester.pumpWidget(_wrap(DunyaDialCodeField(
        onCountryChanged: (_) {},
        pickerMode: DunyaPickerMode.dropdown,
      )));

      await tester.tap(find.text('+--'));
      await tester.pumpAndSettle();

      expect(find.byType(CountryListView), findsOneWidget);
    });
  });

  group('DunyaDialCodeFormField', () {
    testWidgets('a pre-filled number passes validation', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: '50123456');
      await tester.pumpWidget(_wrap(Form(
        key: formKey,
        child: DunyaDialCodeFormField(
          selectedCountry: _kw,
          onCountryChanged: (_) {},
          controller: controller,
          validator: (p) => p != null && p.isValid ? null : 'Invalid',
        ),
      )));

      expect(formKey.currentState!.validate(), isTrue);
    });

    testWidgets('validation error is shown by the field', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(_wrap(Form(
        key: formKey,
        child: DunyaDialCodeFormField(
          selectedCountry: _kw,
          onCountryChanged: (_) {},
          validator: (p) => p != null && p.isValid ? null : 'Invalid',
        ),
      )));

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Invalid'), findsOneWidget);
    });

    testWidgets('follows a swapped controller', (tester) async {
      final formKey = GlobalKey<FormState>();
      PhoneNumber? saved;
      Widget build(TextEditingController c) => _wrap(Form(
            key: formKey,
            child: DunyaDialCodeFormField(
              selectedCountry: _kw,
              onCountryChanged: (_) {},
              controller: c,
              onSaved: (p) => saved = p,
            ),
          ));

      await tester.pumpWidget(build(TextEditingController()));
      final second = TextEditingController();
      await tester.pumpWidget(build(second));
      await tester.pump();

      second.text = '50123456';
      await tester.pump();
      formKey.currentState!.save();
      expect(saved?.e164, '+96550123456');
    });
  });

  group('CountryListView', () {
    Widget list({
      List<Country>? countries,
      List<String> favorites = const [],
      Country? selected,
      double height = 600,
    }) {
      return _wrap(SizedBox(
        height: height,
        child: CountryListView(
          countries: countries ?? CountryRepository.all,
          favorites: favorites,
          selectedCountry: selected,
          onSelected: (_) {},
          searchAutofocus: false,
        ),
      ));
    }

    double scrollOffset(WidgetTester tester) => tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .pixels;

    testWidgets('keeps the search when the parent rebuilds', (tester) async {
      await tester.pumpWidget(list());
      await tester.enterText(find.byType(TextField), 'Kuwait');
      await tester.pump();
      expect(find.byType(CountryListTile), findsOneWidget);

      // A new but equal list, as a parent building `exclude` would pass.
      await tester.pumpWidget(list(countries: [...CountryRepository.all]));
      expect(find.byType(CountryListTile), findsOneWidget);
    });

    testWidgets('no favorites separator while searching', (tester) async {
      await tester.pumpWidget(list(favorites: ['KW', 'SA']));
      await tester.enterText(find.byType(TextField), 'an');
      await tester.pump();

      final thick = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxHeight == 8,
      );
      expect(thick, findsNothing);
    });

    testWidgets('A-Z bar skips favorites', (tester) async {
      await tester.pumpWidget(list(favorites: ['KW']));
      await tester.tap(find.text('K'));
      await tester.pump();

      // Before the fix this jumped to the pinned Kuwait at offset 0.
      expect(scrollOffset(tester), greaterThan(0));
    });

    testWidgets('A-Z jump lands on the first row for the letter',
        (tester) async {
      await tester.pumpWidget(list());
      final firstM = CountryRepository.all.firstWhere(
        (c) => c.name.startsWith('M'),
      );

      await tester.tap(find.text('M'));
      await tester.pump();

      final listTop = tester.getTopLeft(find.byType(ListView)).dy;
      final rowTop = tester.getTopLeft(find.text(firstM.name)).dy;
      final rowOffset = rowTop - listTop;
      // The name sits inside the row; it must be within the first row.
      expect(rowOffset, inInclusiveRange(0, 56));
    });

    testWidgets('A-Z bar hides instead of overflowing', (tester) async {
      await tester.pumpWidget(list(height: 160));
      expect(tester.takeException(), isNull);
    });
  });

  group('CountryListTile', () {
    testWidgets('reads one label without a hardcoded "selected"',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_wrap(CountryListTile(
        country: _kw,
        isSelected: true,
        onTap: () {},
      )));

      expect(find.bySemanticsLabel('Kuwait, +965'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('selected|flag')), findsNothing);
      handle.dispose();
    });

    testWidgets('uses the full locale for translated names', (tester) async {
      CountryLocalizations.register('pt_BR', {'KW': 'Kuaite (BR)'});
      addTearDown(() => CountryLocalizations.unregister('pt_BR'));

      await tester.pumpWidget(Localizations(
        locale: const Locale('pt', 'BR'),
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            child: CountryListTile(
              country: _kw,
              isSelected: false,
              onTap: () {},
            ),
          ),
        ),
      ));

      expect(find.text('Kuaite (BR)'), findsOneWidget);
    });
  });

  group('DunyaCountryPicker', () {
    testWidgets('codeAndArrow trigger hides the country name', (tester) async {
      await tester.pumpWidget(_wrap(DunyaCountryPicker(
        countries: CountryRepository.all,
        selectedCountry: _kw,
        onSelected: (_) {},
        triggerStyle: DunyaPickerTriggerStyle.codeAndArrow,
        selectionLabel: false,
      )));

      expect(find.text('+965'), findsOneWidget);
      expect(find.text('Kuwait'), findsNothing);
    });

    testWidgets('theme parameter reaches the picker sheet', (tester) async {
      await tester.pumpWidget(_wrap(DunyaCountryPicker(
        countries: CountryRepository.all,
        onSelected: (_) {},
        theme: const DunyaPickerTheme(surfaceColor: _red),
      )));

      await tester.tap(find.byType(DunyaCountryPicker));
      await tester.pumpAndSettle();

      final listContext = tester.element(find.byType(CountryListView));
      expect(DunyaPickerTheme.of(listContext).surfaceColor, _red);
    });

    testWidgets('theme parameter reaches the Cupertino dialog', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await tester.pumpWidget(_wrap(DunyaCountryPicker(
        countries: CountryRepository.all,
        onSelected: (_) {},
        mode: DunyaPickerMode.dialog,
        adaptive: true,
        theme: const DunyaPickerTheme(surfaceColor: _red),
      )));

      await tester.tap(find.byType(DunyaCountryPicker));
      await tester.pumpAndSettle();

      final listContext = tester.element(find.byType(CountryListView));
      final color = DunyaPickerTheme.of(listContext).surfaceColor;
      debugDefaultTargetPlatformOverride = null;
      expect(color, _red);
    });

    testWidgets('theme parameter reaches the dropdown overlay', (tester) async {
      await tester.pumpWidget(_wrap(DunyaCountryPicker(
        countries: CountryRepository.all,
        onSelected: (_) {},
        mode: DunyaPickerMode.dropdown,
        theme: const DunyaPickerTheme(surfaceColor: _red),
      )));

      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();

      final listContext = tester.element(find.byType(CountryListView));
      expect(DunyaPickerTheme.of(listContext).surfaceColor, _red);
    });

    testWidgets('bottom sheet hands its scroll controller to the list',
        (tester) async {
      await tester.pumpWidget(_wrap(DunyaCountryPicker(
        countries: CountryRepository.all,
        onSelected: (_) {},
      )));

      await tester.tap(find.byType(DunyaCountryPicker));
      await tester.pumpAndSettle();

      final view = tester.widget<CountryListView>(find.byType(CountryListView));
      expect(view.scrollController, isNotNull);
    });

    testWidgets('dropdown closes when a route is pushed', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(_wrap(
        DunyaCountryPicker(
          countries: CountryRepository.all,
          onSelected: (_) {},
          mode: DunyaPickerMode.dropdown,
        ),
        navigatorKey: navigatorKey,
      ));

      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      expect(find.byType(CountryListView), findsOneWidget);

      navigatorKey.currentState!.push(MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Next page')),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Next page'), findsOneWidget);
      expect(find.byType(CountryListView), findsNothing);
    });
  });
}
