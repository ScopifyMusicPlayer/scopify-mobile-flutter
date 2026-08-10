import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/primary_page_header.dart';
import 'package:scopify_mobile/pages/my/components/my_section_content.dart';
import 'package:scopify_mobile/pages/my/providers/my_content_provider.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

class MyPage extends ConsumerWidget {
  const MyPage({required this.fixtureMode, required this.guest, super.key});

  final FixtureMode fixtureMode;
  final bool guest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(myContentProvider(fixtureMode));

    void navigate({FixtureMode? mode, bool? guestMode}) {
      MyRoute(
        fixture: (mode ?? fixtureMode).queryValue,
        guest: guestMode ?? guest,
      ).go(context);
    }

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: PrimaryPageHeader(
              title: '我的',
              subtitle: guest ? '游客模式' : '你的音乐与收藏',
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
            child: guest
                ? ScopifyEmptyState(
                    title: '登录后，把音乐留在这里',
                    description: '二维码登录会在 M3 接入；游客也可以继续浏览和播放公开内容。',
                    actionLabel: '查看登录态',
                    onAction: () => navigate(guestMode: false),
                  )
                : content.when(
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
                        fixture: fixture,
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
  const _SignedInHub({required this.fixture, required this.onOpen});

  final MyFixture fixture;
  final ValueChanged<dynamic> onOpen;

  @override
  Widget build(BuildContext context) {
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
                    seed: 'momo-profile',
                    circular: true,
                    semanticLabel: 'Momo 的头像',
                  ),
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Momo Super Cool',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        '12 个关注 · 34 位粉丝',
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
                  playlists: fixture.playlists,
                  kind: '歌单',
                  onOpen: onOpen,
                ),
                MySectionContent(
                  playlists: fixture.playlists.take(2).toList(),
                  kind: '声音单',
                  onOpen: onOpen,
                ),
                MySectionContent(
                  playlists: fixture.playlists.reversed.toList(),
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
