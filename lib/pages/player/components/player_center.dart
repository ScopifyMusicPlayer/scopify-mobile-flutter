import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scopify_mobile/app/theme/app_motion.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';

class PlayerCenter extends StatelessWidget {
  const PlayerCenter({
    required this.track,
    required this.isPlaying,
    required this.showsLyrics,
    super.key,
  });

  final MediaTrack track;
  final bool isPlaying;
  final bool showsLyrics;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.standard,
      child: showsLyrics
          ? _LyricsCenter(key: const ValueKey<String>('lyrics'))
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
  const _LyricsCenter({super.key});

  @override
  Widget build(BuildContext context) {
    const lines = <(String, String, bool)>[
      ('No flask can keep it', '没有什么瓶子能留住它', false),
      ('Bubble up and cut right through', '气泡升起，穿过所有迟疑', false),
      ("But you're someone I believe", '但你是我愿意相信的人', true),
      ('You heat me like a fire', '你像一团火那样温暖我', false),
      ("I can feel it getting brighter", '我感觉一切正在变亮', false),
    ];

    return ListView.separated(
      key: const ValueKey<String>('lyrics-list'),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space20),
      itemCount: lines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.space20),
      itemBuilder: (context, index) {
        final line = lines[index];
        final isActive = line.$3;
        return Opacity(
          opacity: isActive ? 1 : 0.48,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                line.$1,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isActive
                      ? AppTokens.textPrimary
                      : AppTokens.textSecondary,
                  fontSize: isActive ? 24 : 19,
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              Text(line.$2, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}
