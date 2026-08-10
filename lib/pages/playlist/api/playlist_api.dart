import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/pages/playlist/dto/playlist_dto.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class PlaylistApi {
  const PlaylistApi(this._runtime);

  final DioRuntime _runtime;

  Future<PlaylistDetailResponseDto> fetchDetail(String playlistId) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/playlist/detail',
      queryParameters: <String, Object?>{'id': playlistId},
    );
    return PlaylistDetailResponseDto.fromJson(response);
  }

  Future<PlaylistTracksResponseDto> fetchTracks(
    String playlistId, {
    int limit = 100,
  }) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/playlist/track/all',
      queryParameters: <String, Object?>{
        'id': playlistId,
        'limit': limit,
        'offset': 0,
      },
    );
    return PlaylistTracksResponseDto.fromJson(response);
  }
}

final playlistApiProvider = Provider<PlaylistApi>(
  (ref) => PlaylistApi(ref.watch(dioRuntimeProvider)),
);
