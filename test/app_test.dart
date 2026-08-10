import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/layouts/mini_player.dart';
import 'package:scopify_mobile/pages/home/home_page.dart';
import 'package:scopify_mobile/pages/player/player_page.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(child: ScopifyApp(router: createAppRouter())),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpHomeFixture(WidgetTester tester, FixtureMode mode) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: HomePage(fixtureMode: mode)),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('M1 home detail playback and player route are connected', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('早上好，Momo'), findsOneWidget);

    await tester.tap(find.text('今日私藏').first);
    await tester.pumpAndSettle();
    expect(find.text('歌单 · 为你定制'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('发现下一首想听的歌'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('歌单 · 为你定制'), findsOneWidget);

    final playButton = find.byKey(const Key('playlist-play-button'));
    final detailScrollable = find.descendant(
      of: find.byKey(const Key('playlist-detail-scroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      playButton,
      180,
      scrollable: detailScrollable,
    );
    await tester.tap(playButton);
    await tester.pumpAndSettle();
    expect(find.byType(MiniPlayer), findsOneWidget);

    await tester.tap(find.byKey(const Key('mini-player-open')));
    await tester.pumpAndSettle();
    expect(find.byType(PlayerPage), findsOneWidget);
  });

  testWidgets('Drawer exposes global tools from a primary page', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('打开菜单'));
    await tester.pumpAndSettle();
    expect(find.text('网易乐签'), findsOneWidget);
    expect(find.text('检查更新'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    final settingsItem = find.text('设置');
    final drawerScrollable = find.descendant(
      of: find.byKey(const Key('app-drawer-scroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      settingsItem,
      180,
      scrollable: drawerScrollable,
    );
    await tester.tap(settingsItem);
    await tester.pumpAndSettle();
    expect(find.text('后端地址'), findsOneWidget);
  });

  testWidgets('Home fixture exposes loading empty and error states', (
    tester,
  ) async {
    await pumpHomeFixture(tester, FixtureMode.loading);
    expect(find.byType(ScopifyLoadingState), findsOneWidget);

    await pumpHomeFixture(tester, FixtureMode.empty);
    expect(find.text('这里还没有内容'), findsOneWidget);

    await pumpHomeFixture(tester, FixtureMode.error);
    expect(find.text('首页暂时没有加载出来'), findsOneWidget);
  });
}
