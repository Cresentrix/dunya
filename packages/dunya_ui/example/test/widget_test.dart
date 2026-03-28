import 'package:flutter_test/flutter_test.dart';

import 'package:dunya_ui_example/main.dart';

void main() {
  testWidgets('MyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // App title renders
    expect(find.text('Dunya Example'), findsOneWidget);
    // Sections are visible
    expect(find.text('Country Picker'), findsOneWidget);
    expect(find.text('Phone Input'), findsOneWidget);
  });
}
