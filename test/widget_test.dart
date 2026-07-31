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

    // Fast-forward past the splash screen timer
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
