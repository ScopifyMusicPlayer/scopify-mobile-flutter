import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/modules/playback/fake_playback_controller.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(fakePlaybackProvider);
    final track = playback.currentTrack;
    if (track == null) return const SizedBox.shrink();

    return Semantics(
      button: true,
      container: true,
      label: '打开完整播放器',
      child: Material(
        color: AppTokens.surfaceRaised,
        child: InkWell(
          key: const Key('mini-player-open'),
          onTap: () => const PlayerRoute().push(context),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 44,
                    child: MediaArtwork(
                      seed: track.artworkSeed,
                      semanticLabel: track.album,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  ScopifyIconAction(
                    icon: playback.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    tooltip: playback.isPlaying ? '暂停' : '播放',
                    onPressed: () => ref
                        .read(fakePlaybackProvider.notifier)
                        .toggle(demoTrack),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
