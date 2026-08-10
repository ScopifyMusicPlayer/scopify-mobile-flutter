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
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String artworkSeed;
  final Duration duration;

  String get durationLabel {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
