import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

abstract interface class AccountGateway {
  Future<AccountOverview> fetchOverview(SessionProfile session);

  Future<List<RecentTrack>> fetchRecentTracks({int limit = 50});
}

class AccountApi implements AccountGateway {
  const AccountApi(this._runtime);

  final DioRuntime _runtime;

  @override
  Future<AccountOverview> fetchOverview(SessionProfile session) async {
    final responses = await Future.wait(<Future<Map<String, dynamic>>>[
      _runtime.get<Map<String, dynamic>>(
        '/user/detail',
        queryParameters: <String, Object?>{'uid': session.userId},
        requiresSession: true,
      ),
      _runtime.get<Map<String, dynamic>>(
        '/user/playlist',
        queryParameters: <String, Object?>{
          'uid': session.userId,
          'limit': 50,
          'offset': 0,
        },
        requiresSession: true,
      ),
    ]);
    return _overviewFromResponses(
      session: session,
      detail: responses.first,
      playlistResponse: responses.last,
    );
  }

  @override
  Future<List<RecentTrack>> fetchRecentTracks({int limit = 50}) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/record/recent/song',
      queryParameters: <String, Object?>{'limit': limit},
      requiresSession: true,
    );
    final data = _map(response['data']);
    final rawList = data['list'] ?? response['list'];
    if (rawList is! List) return const <RecentTrack>[];
    return rawList
        .whereType<Map>()
        .map(_recentTrackFromEntry)
        .whereType<RecentTrack>()
        .toList(growable: false);
  }
}

AccountOverview _overviewFromResponses({
  required SessionProfile session,
  required Map<String, dynamic> detail,
  required Map<String, dynamic> playlistResponse,
}) {
  final rawProfile = _map(detail['profile']);
  final rawPlaylists = playlistResponse['playlist'];
  final playlists = rawPlaylists is List
      ? rawPlaylists
            .whereType<Map>()
            .map((item) => _playlistFromResponse(_map(item), session.userId))
            .whereType<AccountPlaylist>()
            .toList(growable: false)
      : const <AccountPlaylist>[];
  return AccountOverview(
    profile: AccountProfile(
      userId: _int(rawProfile['userId'], fallback: session.userId),
      nickname: _text(rawProfile['nickname'], fallback: session.nickname),
      avatarUrl: _text(rawProfile['avatarUrl'], fallback: session.avatarUrl),
      signature: _text(rawProfile['signature'], fallback: session.signature),
      followingCount: _int(rawProfile['follows']),
      followerCount: _int(rawProfile['followeds']),
      playlistCount: _int(
        rawProfile['playlistCount'],
        fallback: playlists.length,
      ),
      level: _int(detail['level']),
      listenSongs: _int(detail['listenSongs']),
    ),
    playlists: playlists,
  );
}

AccountPlaylist? _playlistFromResponse(Map<String, Object?> json, int userId) {
  final id = _intOrNull(json['id']);
  if (id == null) return null;
  final creator = _map(json['creator']);
  return AccountPlaylist(
    id: id.toString(),
    name: _text(json['name'], fallback: '未命名歌单'),
    creatorName: _text(creator['nickname'], fallback: '未知用户'),
    trackCount: _int(json['trackCount']),
    artworkUrl: _text(json['coverImgUrl'], fallback: _text(json['picUrl'])),
    isOwnedByCurrentUser: _intOrNull(creator['userId']) == userId,
  );
}

RecentTrack? _recentTrackFromEntry(Map entry) {
  final raw = _map(entry);
  final resource = _map(raw['resourceInfo']);
  final song = _map(raw['data']).isNotEmpty
      ? _map(raw['data'])
      : _map(resource['songData']).isNotEmpty
      ? _map(resource['songData'])
      : _map(raw['song']);
  final id = _intOrNull(song['id']);
  if (id == null) return null;
  final artists = song['ar'] ?? song['artists'];
  final artistNames = artists is List
      ? artists
            .whereType<Map>()
            .map((artist) => _text(_map(artist)['name']))
            .where((name) => name.isNotEmpty)
            .join(' / ')
      : '';
  final album = _map(song['al']).isNotEmpty
      ? _map(song['al'])
      : _map(song['album']);
  final playedAtMilliseconds = _intOrNull(raw['playTime']);
  return RecentTrack(
    track: MediaTrack(
      id: id.toString(),
      title: _text(song['name'], fallback: '未知歌曲'),
      artist: artistNames.isEmpty ? '未知歌手' : artistNames,
      album: _text(album['name'], fallback: '未知专辑'),
      artworkSeed: id.toString(),
      artworkUrl: _text(album['picUrl']),
      duration: Duration(
        milliseconds: _int(song['dt'], fallback: _int(song['duration'])),
      ),
    ),
    playedAt: playedAtMilliseconds == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(playedAtMilliseconds),
  );
}

Map<String, Object?> _map(Object? value) => value is Map
    ? Map<String, Object?>.fromEntries(
        value.entries.map(
          (entry) => MapEntry(entry.key.toString(), entry.value),
        ),
      )
    : const <String, Object?>{};

int _int(Object? value, {int fallback = 0}) => _intOrNull(value) ?? fallback;

int? _intOrNull(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text),
  _ => null,
};

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

final accountApiProvider = Provider<AccountGateway>(
  (ref) => AccountApi(ref.watch(dioRuntimeProvider)),
);
