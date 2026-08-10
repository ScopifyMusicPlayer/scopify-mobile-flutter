import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/pages/search/api/search_api.dart';
import 'package:scopify_mobile/pages/search/dto/search_dto.dart';
import 'package:scopify_mobile/pages/search/search_result.dart';

part 'live_search_provider.g.dart';

@riverpod
Future<List<SearchPlaylistResult>> livePlaylistSearch(
  Ref ref,
  String query,
) async {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) return const <SearchPlaylistResult>[];
  await ref.watch(backendEndpointControllerProvider.future);
  final response = await ref
      .watch(searchApiProvider)
      .searchPlaylists(normalizedQuery);
  return (response.result?.playlists ?? const <PlaylistSearchItemDto>[])
      .where((item) => item.id != null && item.name?.isNotEmpty == true)
      .map((item) {
        final id = item.id!;
        final creator = item.creator?.nickname;
        final count = item.trackCount;
        return SearchPlaylistResult(
          id: id.toString(),
          title: item.name!,
          subtitle: <String>[
            if (creator != null && creator.isNotEmpty) creator,
            if (count != null) '$count 首',
          ].join(' · '),
          artworkSeed: id.toString(),
          artworkUrl: item.coverImgUrl,
        );
      })
      .toList(growable: false);
}
