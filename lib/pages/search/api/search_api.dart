import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/pages/search/dto/search_dto.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class SearchApi {
  const SearchApi(this._runtime);

  final DioRuntime _runtime;

  Future<PlaylistSearchResponseDto> searchPlaylists(
    String keyword, {
    int limit = 30,
  }) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/v1/search/playlist/pc',
      queryParameters: <String, Object?>{
        's': keyword,
        'limit': limit,
        'offset': 0,
      },
    );
    return PlaylistSearchResponseDto.fromJson(response);
  }
}

final searchApiProvider = Provider<SearchApi>(
  (ref) => SearchApi(ref.watch(dioRuntimeProvider)),
);
