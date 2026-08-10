import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class PlaylistContent {
  const PlaylistContent({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorName,
    required this.trackCount,
    required this.artworkSeed,
    required this.tracks,
    this.artworkUrl,
  });

  final String id;
  final String title;
  final String description;
  final String creatorName;
  final int trackCount;
  final String artworkSeed;
  final String? artworkUrl;
  final List<MediaTrack> tracks;

  factory PlaylistContent.fromFixture(PlaylistFixture fixture) {
    return PlaylistContent(
      id: fixture.id,
      title: fixture.title,
      description: fixture.description,
      creatorName: '为你定制',
      trackCount: fixture.tracks.length,
      artworkSeed: fixture.artworkSeed,
      tracks: fixture.tracks,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'description': description,
    'creatorName': creatorName,
    'trackCount': trackCount,
    'artworkSeed': artworkSeed,
    'artworkUrl': artworkUrl,
    'tracks': tracks.map((track) => track.toJson()).toList(),
  };

  factory PlaylistContent.fromJson(Map<String, Object?> json) {
    final rawTracks = json['tracks'];
    final tracks = rawTracks is List
        ? rawTracks
              .whereType<Map>()
              .map(
                (item) => MediaTrack.fromJson(Map<String, Object?>.from(item)),
              )
              .toList(growable: false)
        : const <MediaTrack>[];
    String text(String key, {String fallback = ''}) =>
        json[key] is String ? json[key]! as String : fallback;
    return PlaylistContent(
      id: text('id'),
      title: text('title', fallback: '未命名歌单'),
      description: text('description'),
      creatorName: text('creatorName', fallback: '未知用户'),
      trackCount: json['trackCount'] is int
          ? json['trackCount']! as int
          : tracks.length,
      artworkSeed: text('artworkSeed', fallback: text('id')),
      artworkUrl: json['artworkUrl'] as String?,
      tracks: tracks,
    );
  }
}
