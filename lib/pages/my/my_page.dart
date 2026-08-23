import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/primary_page_header.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/account_overview_provider.dart';
import 'package:scopify_mobile/pages/my/components/my_guest_hub.dart';
import 'package:scopify_mobile/pages/my/components/my_section_content.dart';
import 'package:scopify_mobile/pages/my/providers/my_content_provider.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

class MyPage extends ConsumerWidget {
  const MyPage({required this.fixtureMode, super.key});

  final FixtureMode fixtureMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigate({FixtureMode? mode}) {
      MyRoute(fixture: (mode ?? fixtureMode).queryValue).go(context);
    }

    final sessionAsync = ref.watch(sessionControllerProvider);
    final session = sessionAsync.when(
      data: (value) => value,
      loading: () => const GuestSession(),
      error: (_, _) => const GuestSession(),
    );
    final restoringSession = sessionAsync is AsyncLoading<SessionState>;
    final profile = session is AuthenticatedSession ? session.profile : null;
    final authenticated = profile != null;
    final fixtureContent = authenticated && fixtureMode != FixtureMode.live
        ? ref.watch(myContentProvider(fixtureMode))
        : null;
    final liveContent = authenticated && fixtureMode == FixtureMode.live
        ? ref.watch(accountOverviewProvider)
        : null;

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: PrimaryPageHeader(
              title: '我的',
              subtitle: restoringSession
                  ? '正在恢复账号状态'
                  : authenticated
                  ? '你的音乐与收藏'
                  : '公开内容可正常浏览和播放',
              trailing: PopupMenuButton<FixtureMode>(
                tooltip: '切换我的状态',
                initialValue: fixtureMode,
                onSelected: (mode) => navigate(mode: mode),
                itemBuilder: (context) => FixtureMode.values
                    .map(
                      (mode) => PopupMenuItem<FixtureMode>(
                        value: mode,
                        child: Text('Fixture: ${mode.name}'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: restoringSession
                ? const ScopifyLoadingState()
                : !authenticated
                ? MyGuestHub(onLogin: () => const QrLoginRoute().push(context))
                : fixtureMode == FixtureMode.live
                ? liveContent!.when(
                    loading: () => const ScopifyLoadingState(),
                    error: (_, _) => ScopifyErrorState(
                      title: '账号资料加载失败',
                      description: '请检查网络和登录状态后重试。',
                      onRetry: () => ref.invalidate(accountOverviewProvider),
                    ),
                    data: (overview) => _SignedInHub(
                      overview: overview,
                      onOpen: (playlist) => MyPlaylistRoute(
                        playlistId: playlist.id,
                      ).push(context),
                    ),
                  )
                : fixtureContent!.when(
                    loading: () => const ScopifyLoadingState(),
                    error: (_, _) => ScopifyErrorState(
                      title: '个人内容加载失败',
                      description: '这是 M1 的异常 Fixture，用于验证保留 Shell 的错误承载。',
                      onRetry: () => navigate(mode: FixtureMode.data),
                    ),
                    data: (fixture) {
                      if (fixture.playlists.isEmpty) {
                        return ScopifyEmptyState(
                          title: '你的音乐还在路上',
                          description: '恢复数据 Fixture 后，可以看到音乐、播客和收藏三个区块。',
                          actionLabel: '恢复数据',
                          onAction: () => navigate(mode: FixtureMode.data),
                        );
                      }
                      return _SignedInHub(
                        overview: AccountOverview(
                          profile: AccountProfile.fromSession(profile),
                          playlists: fixture.playlists,
                        ),
                        onOpen: (playlist) => MyPlaylistRoute(
                          playlistId: playlist.id,
                        ).push(context),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SignedInHub extends StatelessWidget {
  const _SignedInHub({required this.overview, required this.onOpen});

  final AccountOverview overview;
  final ValueChanged<AccountPlaylist> onOpen;

  @override
  Widget build(BuildContext context) {
    final profile = overview.profile;
    final ownedPlaylists = overview.playlists
        .where((playlist) => playlist.isOwnedByCurrentUser)
        .toList(growable: false);
    final collectedPlaylists = overview.playlists
        .where((playlist) => !playlist.isOwnedByCurrentUser)
        .toList(growable: false);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space16,
              AppTokens.space12,
              AppTokens.space16,
              AppTokens.space16,
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 68,
                  child: MediaArtwork(
                    seed: profile.avatarUrl.isEmpty
                        ? profile.userId.toString()
                        : profile.avatarUrl,
                    circular: true,
                    semanticLabel: '${profile.nickname} 的头像',
                  ),
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.nickname,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        profile.signature.isEmpty
                            ? '已通过网易云音乐扫码登录'
                            : profile.signature,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTokens.textSecondary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: Row(
              children: <Widget>[
                _ProfileMetric(value: '${profile.followingCount}', label: '关注'),
                _ProfileMetric(value: '${profile.followerCount}', label: '粉丝'),
                _ProfileMetric(value: '${profile.listenSongs}', label: '听歌'),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          const TabBar(
            tabs: <Widget>[
              Tab(text: '音乐'),
              Tab(text: '播客'),
              Tab(text: '收藏'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                MySectionContent(
                  playlists: ownedPlaylists,
                  kind: '歌单',
                  onOpen: onOpen,
                ),
                MySectionContent(
                  playlists: const <AccountPlaylist>[],
                  kind: '声音单',
                  onOpen: onOpen,
                ),
                MySectionContent(
                  playlists: collectedPlaylists,
                  kind: '已收藏',
                  onOpen: onOpen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppTokens.space4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
