import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dunya_ui/dunya_ui.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      extensions: const [DunyaPickerTheme()],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('FlagWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlagWidget(alpha2: 'AE'),
      ));
      expect(find.byType(FlagWidget), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlagWidget(alpha2: 'AE', size: 40),
      ));
      final widget = tester.widget<FlagWidget>(find.byType(FlagWidget));
      expect(widget.size, 40);
    });

    testWidgets('uses custom border radius', (tester) async {
      await tester.pumpWidget(_wrap(
        FlagWidget(alpha2: 'AE', radius: BorderRadius.circular(8)),
      ));
      final widget = tester.widget<FlagWidget>(find.byType(FlagWidget));
      expect(widget.radius, BorderRadius.circular(8));
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlagWidget(alpha2: 'AE'),
      ));
      final semantics = tester.getSemantics(find.byType(FlagWidget));
      expect(semantics.label, 'AE flag');
    });

    testWidgets('shows placeholder for unknown flag', (tester) async {
      await tester.pumpWidget(_wrap(
        const FlagWidget(alpha2: 'XX'),
      ));
      await tester.pumpAndSettle();
      // Should still render without crashing
      expect(find.byType(FlagWidget), findsOneWidget);
    });
  });
}
