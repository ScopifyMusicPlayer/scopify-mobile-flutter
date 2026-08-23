import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/primary_page_header.dart';
import 'package:scopify_mobile/components/shared/section_header.dart';
import 'package:scopify_mobile/pages/home/components/home_recommendation_section.dart';
import 'package:scopify_mobile/pages/home/components/home_shortcut_grid.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';
import 'package:scopify_mobile/pages/home/providers/home_content_provider.dart';
import 'package:scopify_mobile/pages/home/providers/home_greeting_provider.dart';
import 'package:scopify_mobile/pages/home/providers/live_home_content_provider.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

class HomePage extends ConsumerWidget {
  const HomePage({required this.fixtureMode, super.key});

  final FixtureMode fixtureMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = fixtureMode == FixtureMode.live
        ? ref.watch(liveHomeContentProvider)
        : ref.watch(homeContentProvider(fixtureMode));
    final greeting = ref.watch(homeGreetingProvider);

    void setFixtureMode(FixtureMode mode) {
      HomeRoute(fixture: mode.queryValue).go(context);
    }

    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0, 0.32),
            colors: <Color>[Color(0xFF245346), AppTokens.surfaceBase],
          ),
        ),
        child: content.when(
          loading: () => const ScopifyLoadingState(),
          error: (_, _) => ScopifyErrorState(
            title: '首页暂时没有加载出来',
            description: fixtureMode == FixtureMode.live
                ? '请检查设置中的后端地址和网络，然后重试。'
                : '这是可复现的 Fixture 异常状态。',
            onRetry: () {
              if (fixtureMode == FixtureMode.live) {
                ref.invalidate(liveHomeContentProvider);
              } else {
                setFixtureMode(FixtureMode.data);
              }
            },
          ),
          data: (fixture) {
            if (fixture.isEmpty) {
              return ScopifyEmptyState(
                title: '这里还没有内容',
                description: fixtureMode == FixtureMode.live
                    ? '后端暂时没有返回推荐内容。'
                    : '切回数据 Fixture 后，可以继续浏览推荐内容。',
                actionLabel: '恢复数据',
                onAction: () => setFixtureMode(FixtureMode.data),
              );
            }
            return _HomeData(
              fixture: fixture,
              greeting: greeting,
              onOpenPlaylist: (playlist) =>
                  HomePlaylistRoute(playlistId: playlist.id).push(context),
              fixtureMode: fixtureMode,
              onFixtureModeSelected: setFixtureMode,
            );
          },
        ),
      ),
    );
  }
}

class _HomeData extends StatelessWidget {
  const _HomeData({
    required this.fixture,
    required this.greeting,
    required this.onOpenPlaylist,
    required this.fixtureMode,
    required this.onFixtureModeSelected,
  });

  final HomeContent fixture;
  final String greeting;
  final ValueChanged<HomePlaylist> onOpenPlaylist;
  final FixtureMode fixtureMode;
  final ValueChanged<FixtureMode> onFixtureModeSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space4,
        AppTokens.space16,
        AppTokens.space32,
      ),
      children: <Widget>[
        PrimaryPageHeader(
          title: greeting,
          subtitle: '把一天打开得轻一些',
          trailing: PopupMenuButton<FixtureMode>(
            tooltip: '切换首页状态',
            initialValue: fixtureMode,
            onSelected: onFixtureModeSelected,
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
        const SizedBox(height: AppTokens.space8),
        HomeShortcutGrid(playlists: fixture.shortcuts, onOpen: onOpenPlaylist),
        const SizedBox(height: AppTokens.space32),
        SectionHeader(title: '为你推荐', actionLabel: '全部', onAction: () {}),
        const SizedBox(height: AppTokens.space8),
        HomeRecommendationSection(
          playlists: fixture.recommendations,
          onOpen: onOpenPlaylist,
        ),
        const SizedBox(height: AppTokens.space20),
        SectionHeader(title: '今天适合慢一点'),
        const SizedBox(height: AppTokens.space12),
        _FeaturedActivity(
          onOpen: fixture.recommendations.isEmpty
              ? null
              : () => onOpenPlaylist(fixture.recommendations.first),
        ),
      ],
    );
  }
}

class _FeaturedActivity extends StatelessWidget {
  const _FeaturedActivity({this.onOpen});

  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: AppTokens.radiusMedium,
      child: InkWell(
        onTap: onOpen,
        borderRadius: AppTokens.radiusMedium,
        child: Container(
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: const BoxDecoration(
            borderRadius: AppTokens.radiusMedium,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF204A40), AppTokens.surfaceCard],
            ),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppTokens.accent,
                size: 28,
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '本周音乐漫游',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      '把最近喜欢的声音串成一段不赶路的旅程。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTokens.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
