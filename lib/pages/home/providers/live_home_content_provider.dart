import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/pages/home/api/home_api.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';
import 'package:scopify_mobile/pages/home/dto/home_dto.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

part 'live_home_content_provider.g.dart';

const _queryName = 'home.personalizedPlaylists';
const _queryParameters = <String, Object?>{'limit': 12};
const _cachePolicy = QueryCachePolicy(
  freshFor: Duration(minutes: 5),
  maxAge: Duration(hours: 6),
);

@Riverpod(keepAlive: true)
class LiveHomeContent extends _$LiveHomeContent {
  @override
  Future<HomeContent> build() async {
    final endpoint = await ref.watch(backendEndpointControllerProvider.future);
    final cache = ref.watch(queryCacheStoreProvider);
    final key = _cacheKey(endpoint.id);
    final cached = await cache.read(key);
    if (cached != null) {
      final content = HomeContent.fromJson(cached.payload);
      if (cached.isFreshAt(DateTime.now())) return content;
      unawaited(_refreshStale(content, key));
      return content;
    }
    return _fetchAndCache(key);
  }

  Future<void> refresh() async {
    final endpoint = await ref.read(backendEndpointControllerProvider.future);
    final key = _cacheKey(endpoint.id);
    state = const AsyncLoading<HomeContent>();
    state = await AsyncValue.guard(() => _fetchAndCache(key));
  }

  Future<void> _refreshStale(HomeContent stale, QueryCacheKey key) async {
    try {
      state = AsyncData(stale);
      state = AsyncData(await _fetchAndCache(key));
    } catch (_) {
      // Stale content remains visible until its hard expiry.
      state = AsyncData(stale);
    }
  }

  Future<HomeContent> _fetchAndCache(QueryCacheKey key) async {
    final response = await ref
        .read(homeApiProvider)
        .fetchPersonalizedPlaylists(limit: 12);
    final content = _toContent(response);
    await ref
        .read(queryCacheStoreProvider)
        .write(key: key, payload: content.toJson(), policy: _cachePolicy);
    return content;
  }

  QueryCacheKey _cacheKey(String endpointId) => QueryCacheKey(
    endpointId: endpointId,
    accountId: 'public',
    scope: 'public',
    query: _queryName,
    parameters: _queryParameters,
    schemaVersion: 1,
  );
}

HomeContent _toContent(PersonalizedPlaylistsDto response) {
  final playlists = (response.result ?? const <PersonalizedPlaylistDto>[])
      .where((item) => item.id != null && item.name?.isNotEmpty == true)
      .map(
        (item) => HomePlaylist(
          id: item.id.toString(),
          title: item.name!,
          subtitle: item.copywriter?.isNotEmpty == true
              ? item.copywriter!
              : '为你推荐',
          description: item.copywriter ?? '',
          artworkSeed: item.id.toString(),
          artworkUrl: item.picUrl,
        ),
      )
      .toList(growable: false);
  final shortcutCount = playlists.length < 6 ? playlists.length : 6;
  return HomeContent(
    shortcuts: playlists.take(shortcutCount).toList(growable: false),
    recommendations: playlists,
  );
}
