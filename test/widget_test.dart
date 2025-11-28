import 'package:flutter_test/flutter_test.dart';
import 'package:nexly/main.dart';

void main() {
  testWidgets('Nexly app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NexlyApp());

    // Verify that dashboard is displayed
    expect(find.text('Nexly Dashboard'), findsOneWidget);
  });
}
