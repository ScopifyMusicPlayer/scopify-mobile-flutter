import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scopify_mobile/app/theme/app_motion.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/modules/playback/lyric_document.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';

class PlayerCenter extends StatelessWidget {
  const PlayerCenter({
    required this.track,
    required this.isPlaying,
    required this.showsLyrics,
    required this.lyrics,
    required this.position,
    super.key,
  });

  final MediaTrack track;
  final bool isPlaying;
  final bool showsLyrics;
  final LyricDocument? lyrics;
  final Duration position;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.standard,
      child: showsLyrics
          ? _LyricsCenter(
              key: const ValueKey<String>('lyrics'),
              lyrics: lyrics ?? LyricDocument.fixture,
              position: position,
            )
          : _DiscCenter(
              key: const ValueKey<String>('disc'),
              track: track,
              isPlaying: isPlaying,
            ),
    );
  }
}

class _DiscCenter extends StatelessWidget {
  const _DiscCenter({required this.track, required this.isPlaying, super.key});

  final MediaTrack track;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final disc = Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Color(0xCC07090A),
        shape: BoxShape.circle,
        boxShadow: AppTokens.artworkShadow,
      ),
      child: MediaArtwork(
        seed: track.artworkSeed,
        circular: true,
        semanticLabel: '${track.album} 唱片',
      ),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 332, maxHeight: 332),
        child: reduceMotion
            ? disc
            : disc
                  .animate(target: isPlaying ? 1 : 0)
                  .rotate(begin: 0, end: 0.04, duration: AppMotion.slow),
      ),
    );
  }
}

class _LyricsCenter extends StatelessWidget {
  const _LyricsCenter({
    required this.lyrics,
    required this.position,
    super.key,
  });

  final LyricDocument lyrics;
  final Duration position;

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeIndex(lyrics.lines, position);

    return ListView.separated(
      key: const ValueKey<String>('lyrics-list'),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space20),
      itemCount: lyrics.lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.space20),
      itemBuilder: (context, index) {
        final line = lyrics.lines[index];
        final isActive = index == activeIndex;
        return Opacity(
          opacity: isActive ? 1 : 0.48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                line.text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isActive
                      ? AppTokens.textPrimary
                      : AppTokens.textSecondary,
                  fontSize: isActive ? 24 : 19,
                ),
              ),
              if (line.translation != null) ...<Widget>[
                const SizedBox(height: AppTokens.space4),
                Text(
                  line.translation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  int _activeIndex(List<LyricLine> lines, Duration position) {
    var activeIndex = 0;
    for (var index = 0; index < lines.length; index++) {
      if (lines[index].at > position) return activeIndex;
      activeIndex = index;
    }
    return activeIndex;
  }
}
