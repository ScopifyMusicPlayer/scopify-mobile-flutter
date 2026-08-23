import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';

class AccountOverview {
  const AccountOverview({required this.profile, required this.playlists});

  final AccountProfile profile;
  final List<AccountPlaylist> playlists;

  Map<String, Object?> toJson() => <String, Object?>{
    'profile': profile.toJson(),
    'playlists': playlists.map((playlist) => playlist.toJson()).toList(),
  };

  factory AccountOverview.fromJson(Map<String, Object?> json) {
    final playlists = json['playlists'];
    return AccountOverview(
      profile: AccountProfile.fromJson(_map(json['profile'])),
      playlists: playlists is List
          ? playlists
                .whereType<Map>()
                .map((item) => AccountPlaylist.fromJson(_map(item)))
                .toList(growable: false)
          : const <AccountPlaylist>[],
    );
  }
}

class AccountProfile {
  const AccountProfile({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.signature,
    required this.followingCount,
    required this.followerCount,
    required this.playlistCount,
    required this.level,
    required this.listenSongs,
  });

  final int userId;
  final String nickname;
  final String avatarUrl;
  final String signature;
  final int followingCount;
  final int followerCount;
  final int playlistCount;
  final int level;
  final int listenSongs;

  Map<String, Object?> toJson() => <String, Object?>{
    'userId': userId,
    'nickname': nickname,
    'avatarUrl': avatarUrl,
    'signature': signature,
    'followingCount': followingCount,
    'followerCount': followerCount,
    'playlistCount': playlistCount,
    'level': level,
    'listenSongs': listenSongs,
  };

  factory AccountProfile.fromJson(Map<String, Object?> json) => AccountProfile(
    userId: _int(json['userId']),
    nickname: _text(json['nickname'], fallback: '网易云用户'),
    avatarUrl: _text(json['avatarUrl']),
    signature: _text(json['signature']),
    followingCount: _int(json['followingCount']),
    followerCount: _int(json['followerCount']),
    playlistCount: _int(json['playlistCount']),
    level: _int(json['level']),
    listenSongs: _int(json['listenSongs']),
  );

  factory AccountProfile.fromSession(SessionProfile profile) => AccountProfile(
    userId: profile.userId,
    nickname: profile.nickname,
    avatarUrl: profile.avatarUrl,
    signature: profile.signature,
    followingCount: 0,
    followerCount: 0,
    playlistCount: 0,
    level: 0,
    listenSongs: 0,
  );
}

class AccountPlaylist {
  const AccountPlaylist({
    required this.id,
    required this.name,
    required this.creatorName,
    required this.trackCount,
    required this.artworkUrl,
    required this.isOwnedByCurrentUser,
  });

  final String id;
  final String name;
  final String creatorName;
  final int trackCount;
  final String artworkUrl;
  final bool isOwnedByCurrentUser;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'creatorName': creatorName,
    'trackCount': trackCount,
    'artworkUrl': artworkUrl,
    'isOwnedByCurrentUser': isOwnedByCurrentUser,
  };

  factory AccountPlaylist.fromJson(Map<String, Object?> json) =>
      AccountPlaylist(
        id: _text(json['id']),
        name: _text(json['name'], fallback: '未命名歌单'),
        creatorName: _text(json['creatorName'], fallback: '未知用户'),
        trackCount: _int(json['trackCount']),
        artworkUrl: _text(json['artworkUrl']),
        isOwnedByCurrentUser: json['isOwnedByCurrentUser'] == true,
      );
}

class RecentTrack {
  const RecentTrack({required this.track, required this.playedAt});

  final MediaTrack track;
  final DateTime? playedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'track': track.toJson(),
    'playedAtMilliseconds': playedAt?.millisecondsSinceEpoch,
  };

  factory RecentTrack.fromJson(Map<String, Object?> json) {
    final playedAtMilliseconds = _intOrNull(json['playedAtMilliseconds']);
    return RecentTrack(
      track: MediaTrack.fromJson(_map(json['track'])),
      playedAt: playedAtMilliseconds == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(playedAtMilliseconds),
    );
  }
}

Map<String, Object?> _map(Object? value) => value is Map
    ? Map<String, Object?>.fromEntries(
        value.entries.map(
          (entry) => MapEntry(entry.key.toString(), entry.value),
        ),
      )
    : const <String, Object?>{};

int _int(Object? value) => _intOrNull(value) ?? 0;

int? _intOrNull(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text),
  _ => null,
};

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;
