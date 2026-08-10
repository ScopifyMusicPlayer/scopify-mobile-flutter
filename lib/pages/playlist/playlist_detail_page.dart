import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/components/shared/scopify_play_button.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/modules/playback/fake_playback_controller.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/pages/playlist/components/playlist_track_list.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class PlaylistDetailPage extends ConsumerWidget {
  const PlaylistDetailPage({
    required this.playlistId,
    this.eyebrow = '歌单',
    this.titleOverride,
    super.key,
  });

  final String playlistId;
  final String eyebrow;
  final String? titleOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = playlistById(playlistId);
    final playback = ref.watch(fakePlaybackProvider);
    final title = titleOverride ?? playlist.title;

    void play(MediaTrack track) {
      ref.read(fakePlaybackProvider.notifier).play(track);
    }

    return DetailLayout(
      eyebrow: eyebrow,
      trailing: ScopifyIconAction(
        icon: Icons.more_horiz_rounded,
        tooltip: '更多操作',
        onPressed: () {},
      ),
      body: ListView(
        key: const Key('playlist-detail-scroll'),
        padding: const EdgeInsets.fromLTRB(
          AppTokens.space16,
          AppTokens.space8,
          AppTokens.space16,
          AppTokens.space32,
        ),
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 220,
              child: MediaArtwork(
                seed: playlist.artworkSeed,
                shadow: true,
                semanticLabel: '$title 封面',
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          Text('歌单 · 为你定制', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppTokens.space8),
          Text(
            playlist.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space12),
          Text(
            'Scopify · ${playlist.tracks.length} 首',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppTokens.space20),
          Row(
            children: <Widget>[
              ScopifyIconAction(
                icon: Icons.favorite_border_rounded,
                tooltip: '收藏',
                onPressed: () {},
              ),
              ScopifyIconAction(
                icon: Icons.more_horiz_rounded,
                tooltip: '更多',
                onPressed: () {},
              ),
              const Spacer(),
              ScopifyPlayButton(
                key: const Key('playlist-play-button'),
                isPlaying:
                    playback.isPlaying &&
                    playback.currentTrack?.id == playlist.tracks.first.id,
                onPressed: () => play(playlist.tracks.first),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space20),
          Text('曲目', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space8),
          PlaylistTrackList(
            tracks: playlist.tracks,
            currentTrackId: playback.currentTrack?.id,
            onPlay: play,
          ),
        ],
      ),
    );
  }
}
