import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/pages/home/dto/home_dto.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class HomeApi {
  const HomeApi(this._runtime);

  final DioRuntime _runtime;

  Future<PersonalizedPlaylistsDto> fetchPersonalizedPlaylists({
    int limit = 12,
  }) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/personalized',
      queryParameters: <String, Object?>{'limit': limit},
    );
    return PersonalizedPlaylistsDto.fromJson(response);
  }
}

final homeApiProvider = Provider<HomeApi>(
  (ref) => HomeApi(ref.watch(dioRuntimeProvider)),
);
