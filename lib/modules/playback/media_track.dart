import 'package:flutter/foundation.dart';

@immutable
class MediaTrack {
  const MediaTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artworkSeed,
    required this.duration,
    this.artworkUrl,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkSeed;
  final Duration duration;
  final String? artworkUrl;

  String get durationLabel {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'artworkSeed': artworkSeed,
    'artworkUrl': artworkUrl,
    'durationMilliseconds': duration.inMilliseconds,
  };

  factory MediaTrack.fromJson(Map<String, Object?> json) {
    String text(String key, {String fallback = ''}) =>
        json[key] is String ? json[key]! as String : fallback;
    return MediaTrack(
      id: text('id'),
      title: text('title', fallback: '未知歌曲'),
      artist: text('artist', fallback: '未知歌手'),
      album: text('album', fallback: '未知专辑'),
      artworkSeed: text('artworkSeed', fallback: text('id')),
      artworkUrl: json['artworkUrl'] as String?,
      duration: Duration(
        milliseconds: json['durationMilliseconds'] is int
            ? json['durationMilliseconds']! as int
            : 0,
      ),
    );
  }
}
