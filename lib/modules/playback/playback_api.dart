import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/playback/lyric_document.dart';
import 'package:scopify_mobile/modules/playback/lyric_parser.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class ResolvedAudioSource {
  const ResolvedAudioSource({required this.url, this.expiresAt});

  final String url;
  final DateTime? expiresAt;
}

class PlaybackApi {
  const PlaybackApi(this._runtime);

  final DioRuntime _runtime;

  Future<ResolvedAudioSource> resolveAudioUrl(String trackId) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/song/url/v1',
      queryParameters: <String, Object?>{'id': trackId, 'level': 'exhigh'},
    );
    final data = response['data'];
    final first = data is List && data.isNotEmpty && data.first is Map
        ? Map<Object?, Object?>.from(data.first as Map)
        : null;
    final url = first?['url'];
    if (url is! String || url.isEmpty) {
      throw AppFailure.business(message: '当前歌曲暂无可用播放地址。');
    }
    final expiresAt = first?['expi'] is num
        ? DateTime.now().add(
            Duration(milliseconds: (first!['expi'] as num).toInt()),
          )
        : null;
    return ResolvedAudioSource(url: url, expiresAt: expiresAt);
  }

  Future<LyricDocument> fetchLyrics(String trackId) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/lyric/new',
      queryParameters: <String, Object?>{'id': trackId},
    );
    String? lyricFor(String key) {
      final item = response[key];
      return item is Map && item['lyric'] is String
          ? item['lyric'] as String
          : null;
    }

    return LyricParser.parse(
      primary: lyricFor('yrc') ?? lyricFor('lrc'),
      translated: lyricFor('tlyric'),
    );
  }
}

final playbackApiProvider = Provider<PlaybackApi>(
  (ref) => PlaybackApi(ref.watch(dioRuntimeProvider)),
);
