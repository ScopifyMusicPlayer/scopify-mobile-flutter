import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/pages/playlist/api/playlist_api.dart';
import 'package:scopify_mobile/pages/playlist/dto/playlist_dto.dart';
import 'package:scopify_mobile/pages/playlist/playlist_content.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

part 'live_playlist_content_provider.g.dart';

const _cachePolicy = QueryCachePolicy(
  freshFor: Duration(minutes: 15),
  maxAge: Duration(hours: 24),
);

@riverpod
class LivePlaylistContent extends _$LivePlaylistContent {
  @override
  Future<PlaylistContent> build(String playlistId) async {
    final endpoint = await ref.watch(backendEndpointControllerProvider.future);
    final key = _cacheKey(endpoint.id, playlistId);
    final cache = ref.watch(queryCacheStoreProvider);
    final cached = await cache.read(key);
    if (cached != null) {
      final content = PlaylistContent.fromJson(cached.payload);
      if (cached.isFreshAt(DateTime.now())) return content;
      unawaited(_refreshStale(content, key));
      return content;
    }
    return _fetchAndCache(key, playlistId);
  }

  Future<void> refresh() async {
    final endpoint = await ref.read(backendEndpointControllerProvider.future);
    final key = _cacheKey(endpoint.id, playlistId);
    state = const AsyncLoading<PlaylistContent>();
    state = await AsyncValue.guard(() => _fetchAndCache(key, playlistId));
  }

  Future<void> _refreshStale(PlaylistContent stale, QueryCacheKey key) async {
    try {
      state = AsyncData(stale);
      state = AsyncData(await _fetchAndCache(key, playlistId));
    } catch (_) {
      state = AsyncData(stale);
    }
  }

  Future<PlaylistContent> _fetchAndCache(
    QueryCacheKey key,
    String playlistId,
  ) async {
    final api = ref.read(playlistApiProvider);
    final responses = await Future.wait(<Future<Object>>[
      api.fetchDetail(playlistId),
      api.fetchTracks(playlistId),
    ]);
    final content = _toContent(
      responses[0] as PlaylistDetailResponseDto,
      responses[1] as PlaylistTracksResponseDto,
      playlistId,
    );
    await ref
        .read(queryCacheStoreProvider)
        .write(key: key, payload: content.toJson(), policy: _cachePolicy);
    return content;
  }

  QueryCacheKey _cacheKey(String endpointId, String playlistId) =>
      QueryCacheKey(
        endpointId: endpointId,
        accountId: 'public',
        scope: 'public',
        query: 'playlist.content',
        parameters: <String, Object?>{'id': playlistId, 'limit': 100},
        schemaVersion: 1,
      );
}

PlaylistContent _toContent(
  PlaylistDetailResponseDto detail,
  PlaylistTracksResponseDto tracksResponse,
  String requestedId,
) {
  final playlist = detail.playlist;
  final tracks = (tracksResponse.songs ?? const <PlaylistSongDto>[])
      .where((song) => song.id != null && song.name?.isNotEmpty == true)
      .map((song) {
        final artists = (song.ar ?? const <PlaylistArtistDto>[])
            .map((artist) => artist.name)
            .whereType<String>()
            .where((name) => name.isNotEmpty)
            .join(' / ');
        final id = song.id!;
        return MediaTrack(
          id: id.toString(),
          title: song.name!,
          artist: artists.isEmpty ? '未知歌手' : artists,
          album: song.al?.name ?? '未知专辑',
          artworkSeed: id.toString(),
          artworkUrl: song.al?.picUrl,
          duration: Duration(milliseconds: song.dt ?? 0),
        );
      })
      .toList(growable: false);
  return PlaylistContent(
    id: playlist?.id?.toString() ?? requestedId,
    title: playlist?.name?.isNotEmpty == true ? playlist!.name! : '未命名歌单',
    description: playlist?.description ?? '',
    creatorName: playlist?.creator?.nickname ?? '未知用户',
    trackCount: playlist?.trackCount ?? tracks.length,
    artworkSeed: playlist?.id?.toString() ?? requestedId,
    artworkUrl: playlist?.coverImgUrl,
    tracks: tracks,
  );
}
