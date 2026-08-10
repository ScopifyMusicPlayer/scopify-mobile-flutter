import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/primary_page_header.dart';
import 'package:scopify_mobile/pages/search/components/search_result_list.dart';
import 'package:scopify_mobile/pages/search/providers/live_search_provider.dart';
import 'package:scopify_mobile/pages/search/providers/search_content_provider.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({required this.fixtureMode, super.key});

  final FixtureMode fixtureMode;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String value, {bool immediately = false}) {
    _debounce?.cancel();
    if (immediately) {
      setState(() => _query = value);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _chooseSuggestion(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _setQuery(value, immediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.fixtureMode == FixtureMode.live;
    final query = _query.trim();
    final fixtureResults = ref.watch(searchContentProvider(widget.fixtureMode));
    final liveResults = isLive && query.isNotEmpty
        ? ref.watch(livePlaylistSearchProvider(query))
        : null;
    final results = liveResults ?? fixtureResults;

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
                initialValue: widget.fixtureMode,
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
              controller: _controller,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: '搜索歌曲、歌手或歌单',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: _setQuery,
              onSubmitted: (value) => _setQuery(value, immediately: true),
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppTokens.space8,
                children: <String>['周杰伦', '陈奕迅', '爵士', '学习']
                    .map(
                      (suggestion) => ActionChip(
                        label: Text(suggestion),
                        onPressed: () => _chooseSuggestion(suggestion),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          Expanded(
            child: isLive && query.isEmpty
                ? const _SearchDiscoverState()
                : results.when(
                    loading: () => const ScopifyLoadingState(),
                    error: (_, _) => ScopifyErrorState(
                      title: '搜索结果加载失败',
                      description: isLive
                          ? '请检查后端地址和网络，然后重试。'
                          : '切回数据 Fixture 可以继续检查页面链路。',
                      onRetry: () {
                        if (isLive) {
                          ref.invalidate(livePlaylistSearchProvider(query));
                        } else {
                          setFixtureMode(FixtureMode.data);
                        }
                      },
                    ),
                    data: (items) {
                      if (items.isEmpty) {
                        return ScopifyEmptyState(
                          title: '没有找到对应内容',
                          description: isLive
                              ? '换一个关键词，或者从上方热门搜索开始。'
                              : '换一个关键词，或者恢复 Fixture 数据继续体验。',
                          actionLabel: isLive ? '搜索周杰伦' : '恢复数据',
                          onAction: () => isLive
                              ? _chooseSuggestion('周杰伦')
                              : setFixtureMode(FixtureMode.data),
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

class _SearchDiscoverState extends StatelessWidget {
  const _SearchDiscoverState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.travel_explore_rounded,
              size: 42,
              color: AppTokens.accent,
            ),
            const SizedBox(height: AppTokens.space12),
            Text('输入关键词开始搜索', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space4),
            Text(
              'M2 当前接入公开歌单搜索；歌曲、歌手和更多分类会沿用同一数据链路扩展。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
