import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';

class PlaylistTrackList extends StatelessWidget {
  const PlaylistTrackList({
    required this.tracks,
    required this.currentTrackId,
    required this.onPlay,
    super.key,
  });

  final List<MediaTrack> tracks;
  final String? currentTrackId;
  final ValueChanged<MediaTrack> onPlay;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tracks.length,
      separatorBuilder: (_, _) => const Divider(indent: 68),
      itemBuilder: (context, index) {
        final track = tracks[index];
        final isCurrent = track.id == currentTrackId;
        return InkWell(
          onTap: () => onPlay(track),
          borderRadius: AppTokens.radiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 24,
                  child: Text(
                    isCurrent ? '•' : '${index + 1}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isCurrent
                          ? AppTokens.accent
                          : AppTokens.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space8),
                SizedBox(
                  width: 48,
                  child: MediaArtwork(seed: track.artworkSeed),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        track.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: isCurrent ? AppTokens.accent : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${track.artist} · ${track.album}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Text(
                  track.durationLabel,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                ScopifyIconAction(
                  icon: Icons.more_horiz_rounded,
                  tooltip: '${track.title} 的更多操作',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
