import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/api/account_api.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

const _recentTracksPolicy = QueryCachePolicy(
  freshFor: Duration(minutes: 2),
  maxAge: Duration(hours: 6),
);

final recentTracksProvider = FutureProvider<List<RecentTrack>>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);
  if (session is! AuthenticatedSession) {
    throw StateError('需要登录后才能读取最近播放。');
  }
  final endpoint = await ref.watch(backendEndpointControllerProvider.future);
  final cache = ref.watch(queryCacheStoreProvider);
  final key = QueryCacheKey(
    endpointId: endpoint.id,
    accountId: session.profile.userId.toString(),
    scope: 'account',
    query: 'account.recentTracks',
    parameters: const <String, Object?>{'limit': 50},
    schemaVersion: 1,
  );
  final cached = await cache.read(key);
  if (cached != null && cached.isFreshAt(DateTime.now())) {
    final tracks = cached.payload['tracks'];
    return tracks is List
        ? tracks
              .whereType<Map>()
              .map(
                (track) => RecentTrack.fromJson(
                  Map<String, Object?>.fromEntries(
                    track.entries.map(
                      (entry) => MapEntry(entry.key.toString(), entry.value),
                    ),
                  ),
                ),
              )
              .toList(growable: false)
        : const <RecentTrack>[];
  }

  final tracks = await ref
      .read(accountApiProvider)
      .fetchRecentTracks(limit: 50);
  await cache.write(
    key: key,
    payload: <String, Object?>{
      'tracks': tracks.map((track) => track.toJson()).toList(),
    },
    policy: _recentTracksPolicy,
  );
  return tracks;
});
