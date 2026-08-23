import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_api.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_controller.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/account_overview_provider.dart';

import '../../support/session_fakes.dart';

const _onePixelPng =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwC'
    'AAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

class _WaitingQrLoginGateway implements QrLoginGateway {
  @override
  Future<QrLoginCheck> check(String key) async => const QrLoginCheck(code: 801);

  @override
  Future<QrLoginImage> create(String key) async =>
      const QrLoginImage(_onePixelPng);

  @override
  Future<QrLoginKey> requestKey() async => const QrLoginKey('test-key');
}

Widget _guestScope({required Widget child}) {
  return ProviderScope(
    overrides: [
      credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
      sessionApiProvider.overrideWithValue(FakeSessionGateway()),
      qrLoginApiProvider.overrideWithValue(_WaitingQrLoginGateway()),
      qrPollingDelayProvider.overrideWithValue(() => Completer<void>().future),
    ],
    child: child,
  );
}

Widget _authenticatedScope({required Widget child}) {
  return ProviderScope(
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
      accountOverviewProvider.overrideWith(
        (ref) async => AccountOverview(
          profile: const AccountProfile(
            userId: 42,
            nickname: '测试用户',
            avatarUrl: '',
            signature: '正在听喜欢的歌',
            followingCount: 3,
            followerCount: 4,
            playlistCount: 1,
            level: 5,
            listenSongs: 12,
          ),
          playlists: const <AccountPlaylist>[],
        ),
      ),
    ],
    child: child,
  );
}

void main() {
  testWidgets('My keeps its page structure visible for a guest', (
    tester,
  ) async {
    await tester.pumpWidget(
      _guestScope(
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
      _guestScope(
        child: ScopifyApp(router: createAppRouter(initialLocation: '/my')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('扫码登录'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('qr-login-page')), findsOneWidget);
    expect(find.text('打开 App 扫一扫登录'), findsOneWidget);
    expect(find.text('测试用户'), findsNothing);
  });

  testWidgets('restored session reveals the signed-in My hub', (tester) async {
    await tester.pumpWidget(
      _authenticatedScope(
        child: ScopifyApp(router: createAppRouter(initialLocation: '/my')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('测试用户'), findsOneWidget);
    expect(find.text('正在听喜欢的歌'), findsOneWidget);
    expect(find.text('登录后同步你的音乐库'), findsNothing);
  });
}
