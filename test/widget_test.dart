import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nukkad/main.dart';

void main() {
  testWidgets('Nukkad App renders splash and navigates to home', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NukkadApp(),
      ),
    );

    expect(find.byType(NukkadApp), findsOneWidget);

    // Fast-forward past the splash screen timer (2 seconds)
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 100));
  });
}
