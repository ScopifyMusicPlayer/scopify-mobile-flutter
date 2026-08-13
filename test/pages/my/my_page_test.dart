import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';

void main() {
  testWidgets('My keeps its page structure visible for a guest', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScopifyApp(router: createAppRouter(initialLocation: '/my')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后同步你的音乐库'), findsOneWidget);
    expect(find.text('登录后查看你的音乐与歌单'), findsOneWidget);
    expect(find.text('Momo Super Cool'), findsNothing);

    await tester.tap(find.text('播客').first);
    await tester.pumpAndSettle();

    expect(find.text('登录后查看订阅的播客'), findsOneWidget);
  });

  testWidgets('guest login actions do not fake an authenticated session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: ScopifyApp(router: createAppRouter(initialLocation: '/my')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('扫码登录'));
    await tester.pumpAndSettle();

    expect(find.text('二维码登录将在 M3 接入。'), findsOneWidget);
    expect(find.text('Momo Super Cool'), findsNothing);
  });
}
