import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/scopify_app.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/recent_tracks_provider.dart';

import '../../support/session_fakes.dart';

final _recentTracks = <RecentTrack>[
  RecentTrack(
    track: const MediaTrack(
      id: 'track-1',
      title: '真实播放歌曲',
      artist: '真实歌手',
      album: '真实专辑',
      artworkSeed: 'track-1',
      duration: Duration(minutes: 3, seconds: 12),
    ),
    playedAt: DateTime(2026, 8, 23, 10),
  ),
];

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
            signature: '',
          ),
        ),
      ),
      recentTracksProvider.overrideWith((ref) async => _recentTracks),
    ],
    child: child,
  );
}

void main() {
  testWidgets('guest Recent page asks for QR login', (tester) async {
    await tester.pumpWidget(
      _scope(
        authenticated: false,
        child: ScopifyApp(router: createAppRouter(initialLocation: '/recent')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('扫码登录后查看最近播放'), findsOneWidget);
    expect(find.text('真实播放歌曲'), findsNothing);
  });

  testWidgets('authenticated Recent page renders account history', (
    tester,
  ) async {
    await tester.pumpWidget(
      _scope(
        authenticated: true,
        child: ScopifyApp(router: createAppRouter(initialLocation: '/recent')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('真实播放歌曲'), findsOneWidget);
    expect(find.textContaining('真实歌手'), findsOneWidget);
    expect(find.text('3:12'), findsOneWidget);
  });
}
