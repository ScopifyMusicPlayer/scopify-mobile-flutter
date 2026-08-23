import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';
import 'package:scopify_mobile/components/shared/scopify_pill_button.dart';

void main() {
  testWidgets('uses the shared pill action seam for a primary action', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: ScopifyPillButton(
            label: '签到',
            icon: Icons.check_rounded,
            onPressed: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('签到'), findsOneWidget);
    await tester.tap(find.text('签到'));
    expect(taps, 1);
  });

  testWidgets('does not expose a tap while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: ScopifyPillButton(
            label: '签到中',
            onPressed: () => taps++,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('签到中'));
    expect(taps, 0);
  });
}
