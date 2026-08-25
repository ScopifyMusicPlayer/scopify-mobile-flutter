import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/account_overview_provider.dart';

import '../../support/session_fakes.dart';

final _overview = AccountOverview(
  profile: const AccountProfile(
    userId: 88,
    nickname: '真实账号',
    avatarUrl: '',
    signature: '正在播放收藏的歌',
    followingCount: 12,
    followerCount: 34,
    playlistCount: 2,
    level: 7,
    listenSongs: 456,
  ),
  playlists: const <AccountPlaylist>[
    AccountPlaylist(
      id: 'playlist-1',
      name: '我的收藏',
      creatorName: '真实账号',
      trackCount: 18,
      artworkUrl: '',
      isOwnedByCurrentUser: true,
    ),
  ],
);

Widget _scope({required Widget child, required bool authenticated}) {
  return ProviderScope(
    overrides: [
      credentialStoreProvider.overrideWithValue(
        MemoryCredentialStore(
          credential: authenticated
              ? const StoredSessionCredential(
                  cookie: 'music-cookie',
                  endpointId: 'http://10.0.2.2:3838',
                )
              : null,
        ),
      ),
      sessionApiProvider.overrideWithValue(
        FakeSessionGateway(
          profile: const SessionProfile(
            userId: 88,
            nickname: '真实账号',
            avatarUrl: '',
            signature: '正在播放收藏的歌',
          ),
        ),
      ),
      accountOverviewProvider.overrideWith((ref) async => _overview),
    ],
    child: child,
  );
}

void main() {
  testWidgets('guest Profile remains a QR login gate', (tester) async {
    await tester.pumpWidget(
      _scope(
        authenticated: false,
        child: ScopifyApp(router: createAppRouter(initialLocation: '/profile')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('登录后查看个人资料'), findsOneWidget);
    expect(find.text('扫码登录'), findsOneWidget);
    expect(find.text('真实账号'), findsNothing);
  });

  testWidgets('authenticated Profile renders account API data', (tester) async {
    await tester.pumpWidget(
      _scope(
        authenticated: true,
        child: ScopifyApp(router: createAppRouter(initialLocation: '/profile')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('真实账号'), findsOneWidget);
    expect(find.text('正在播放收藏的歌'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
    expect(find.text('我的收藏'), findsOneWidget);
    expect(find.textContaining('18 首'), findsOneWidget);
  });
}
