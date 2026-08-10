import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/primary_page_header.dart';
import 'package:scopify_mobile/pages/search/components/search_result_list.dart';
import 'package:scopify_mobile/pages/search/providers/search_content_provider.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({required this.fixtureMode, super.key});

  final FixtureMode fixtureMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchContentProvider(fixtureMode));

    void setFixtureMode(FixtureMode mode) {
      SearchRoute(fixture: mode.queryValue).go(context);
    }

    return SafeArea(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: PrimaryPageHeader(
              title: '搜索',
              subtitle: '发现下一首想听的歌',
              trailing: PopupMenuButton<FixtureMode>(
                tooltip: '切换搜索状态',
                initialValue: fixtureMode,
                onSelected: setFixtureMode,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: TextField(
              readOnly: true,
              decoration: const InputDecoration(
                hintText: '搜索歌曲、歌手或歌单',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onTap: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('真实搜索将在 M2 接入。'))),
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppTokens.space8,
                children: const <Widget>[
                  Chip(label: Text('流行')),
                  Chip(label: Text('爵士')),
                  Chip(label: Text('播客')),
                  Chip(label: Text('学习')),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          Expanded(
            child: results.when(
              loading: () => const ScopifyLoadingState(),
              error: (_, _) => ScopifyErrorState(
                title: '搜索结果加载失败',
                description: '切回数据 Fixture 可以继续检查页面链路。',
                onRetry: () => setFixtureMode(FixtureMode.data),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ScopifyEmptyState(
                    title: '没有找到对应内容',
                    description: '换一个关键词，或者恢复 Fixture 数据继续体验。',
                    actionLabel: '恢复数据',
                    onAction: () => setFixtureMode(FixtureMode.data),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space16,
                  ),
                  child: SearchResultList(
                    results: items,
                    onOpen: (playlist) => SearchPlaylistRoute(
                      playlistId: playlist.id,
                    ).push(context),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
