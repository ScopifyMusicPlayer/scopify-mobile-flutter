import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';
import 'package:scopify_mobile/app/theme/app_theme.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/scopify_pill_button.dart';
import 'package:scopify_mobile/layouts/mini_player.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_cache_cleanup.dart';
import 'package:scopify_mobile/modules/session/session_expiry_bus.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/api/vip_sign_api.dart';
import 'package:scopify_mobile/pages/account/providers/vip_sign_provider.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';
import 'package:scopify_mobile/pages/home/home_page.dart';
import 'package:scopify_mobile/pages/home/providers/home_greeting_provider.dart';
import 'package:scopify_mobile/pages/player/player_page.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

import 'support/session_fakes.dart';
import 'support/vip_sign_fakes.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
        sessionApiProvider.overrideWithValue(FakeSessionGateway()),
        homeClockProvider.overrideWithValue(() => DateTime(2026, 8, 23, 8)),
      ],
      child: ScopifyApp(
        router: createAppRouter(initialLocation: '/?fixture=data'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpHomeFixture(WidgetTester tester, FixtureMode mode) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
        sessionApiProvider.overrideWithValue(FakeSessionGateway()),
        homeClockProvider.overrideWithValue(() => DateTime(2026, 8, 23, 8)),
      ],
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

    expect(find.text('早上好'), findsOneWidget);

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
    expect(find.text('使用二维码登录'), findsOneWidget);
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

  testWidgets('Home greeting uses the authenticated session nickname', (
    tester,
  ) async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'music-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final api = FakeSessionGateway(
      profile: const SessionProfile(
        userId: 88,
        nickname: '登录用户',
        avatarUrl: '',
        signature: '',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialStoreProvider.overrideWithValue(store),
          sessionApiProvider.overrideWithValue(api),
          homeClockProvider.overrideWithValue(
            () => DateTime(2026, 8, 23, 10, 7),
          ),
        ],
        child: ScopifyApp(
          router: createAppRouter(initialLocation: '/?fixture=data'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('下午好，登录用户'), findsOneWidget);
    expect(find.text('早上好，Momo'), findsNothing);
  });

  testWidgets('expired session preserves the current route and playback', (
    tester,
  ) async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'music-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final expiryBus = SessionExpiryBus();
    addTearDown(expiryBus.close);
    final clearedAccounts = <String>[];

    Future<void> clearAccountCache({
      required String endpointId,
      required String accountId,
    }) async {
      clearedAccounts.add(accountId);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialStoreProvider.overrideWithValue(store),
          sessionApiProvider.overrideWithValue(FakeSessionGateway()),
          sessionExpiryBusProvider.overrideWithValue(expiryBus),
          accountCacheClearerProvider.overrideWithValue(clearAccountCache),
          vipSignHistoryProvider.overrideWith(
            (ref) async => defaultVipSignHistory,
          ),
        ],
        child: ScopifyApp(
          router: createAppRouter(initialLocation: '/?fixture=data'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('今日私藏').first);
    await tester.pumpAndSettle();
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

    expiryBus.notifyExpired();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-expired-modal')), findsOneWidget);
    expect(find.text('登录状态已过期'), findsOneWidget);
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.text('歌单 · 为你定制'), findsOneWidget);
    expect(store.credential, isNull);
    expect(clearedAccounts, <String>['42']);

    await tester.tap(find.byKey(const Key('session-continue-guest')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('session-expired-modal')), findsNothing);
    expect(find.byType(MiniPlayer), findsOneWidget);
    expect(find.text('歌单 · 为你定制'), findsOneWidget);
  });

  testWidgets('authenticated Drawer can explicitly sign out', (tester) async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'music-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final api = FakeSessionGateway();

    Future<void> clearAccountCache({
      required String endpointId,
      required String accountId,
    }) async {}

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialStoreProvider.overrideWithValue(store),
          sessionApiProvider.overrideWithValue(api),
          accountCacheClearerProvider.overrideWithValue(clearAccountCache),
          vipSignHistoryProvider.overrideWith(
            (ref) async => defaultVipSignHistory,
          ),
        ],
        child: ScopifyApp(
          router: createAppRouter(initialLocation: '/?fixture=data'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('打开菜单'));
    await tester.pumpAndSettle();
    expect(find.text('今日已签 · 查看今日乐签'), findsOneWidget);
    expect(find.text('连续签到 1 天'), findsOneWidget);
    final signOutItem = find.text('退出账号');
    final drawerScrollable = find.descendant(
      of: find.byKey(const Key('app-drawer-scroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      signOutItem,
      180,
      scrollable: drawerScrollable,
    );
    await tester.tap(signOutItem);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-sign-out')));
    await tester.pumpAndSettle();

    expect(api.revokedCookies, <String>['music-cookie']);
    expect(store.credential, isNull);
    expect(find.text('已退出账号。'), findsOneWidget);
  });

  testWidgets('authenticated Drawer can submit an unsigned VIP sign', (
    tester,
  ) async {
    const unsignedHistory = VipSignHistory(
      days: <VipSignDay>[
        VipSignDay(
          dayText: '23日',
          isSigned: false,
          songCoverUrl: '',
          signTime: 1724400000000,
          isToday: true,
        ),
      ],
      subText: '连续签到 0 天',
      buttonText: '今日签到',
    );
    final gateway = FakeVipSignGateway(
      history: unsignedHistory,
      result: const VipSignResult(signed: true, message: '签到成功'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          credentialStoreProvider.overrideWithValue(
            MemoryCredentialStore(
              credential: const StoredSessionCredential(
                cookie: 'music-cookie',
                endpointId: 'http://10.0.2.2:3838',
              ),
            ),
          ),
          sessionApiProvider.overrideWithValue(FakeSessionGateway()),
          vipSignHistoryProvider.overrideWith((ref) async => unsignedHistory),
          vipSignApiProvider.overrideWithValue(gateway),
        ],
        child: ScopifyApp(
          router: createAppRouter(initialLocation: '/?fixture=data'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('打开菜单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('今日未签 · 查看签到状态'));
    await tester.pumpAndSettle();
    expect(find.text('今日签到'), findsOneWidget);
    expect(find.text('签到成功后会刷新今日状态，不会重复提交。'), findsOneWidget);

    await tester.tap(find.byType(ScopifyPillButton).last);
    await tester.pumpAndSettle();

    expect(gateway.signCount, 1);
    expect(find.text('签到成功'), findsOneWidget);
  });
}
