import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/main.dart';

void main() {
  testWidgets('shows the Scopify app name', (tester) async {
    await tester.pumpWidget(const ScopifyApp());

    expect(find.text('Scopify'), findsOneWidget);
  });
}
