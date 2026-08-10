import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/components/shared/scopify_play_button.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/modules/playback/foreground_playback_controller.dart';
import 'package:scopify_mobile/modules/playback/media_track.dart';
import 'package:scopify_mobile/pages/playlist/components/playlist_track_list.dart';
import 'package:scopify_mobile/pages/playlist/playlist_content.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/pages/playlist/providers/live_playlist_content_provider.dart';

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
    final AsyncValue<PlaylistContent> content = isFixturePlaylistId(playlistId)
        ? AsyncData<PlaylistContent>(
            PlaylistContent.fromFixture(playlistById(playlistId)),
          )
        : ref.watch(livePlaylistContentProvider(playlistId));
    final playback = ref.watch(foregroundPlaybackProvider);

    return content.when(
      loading: () =>
          DetailLayout(eyebrow: eyebrow, body: const ScopifyLoadingState()),
      error: (_, _) => DetailLayout(
        eyebrow: eyebrow,
        body: ScopifyErrorState(
          title: '歌单暂时没有加载出来',
          description: '请检查后端地址和网络，然后重试。',
          onRetry: () =>
              ref.invalidate(livePlaylistContentProvider(playlistId)),
        ),
      ),
      data: (playlist) => _PlaylistDetailData(
        eyebrow: eyebrow,
        playlist: playlist,
        titleOverride: titleOverride,
        playback: playback,
        onPlay: (track) => ref
            .read(foregroundPlaybackProvider.notifier)
            .playQueue(
              playlist.tracks,
              startIndex: playlist.tracks.indexOf(track),
            ),
      ),
    );
  }
}

class _PlaylistDetailData extends StatelessWidget {
  const _PlaylistDetailData({
    required this.eyebrow,
    required this.playlist,
    required this.titleOverride,
    required this.playback,
    required this.onPlay,
  });

  final String eyebrow;
  final PlaylistContent playlist;
  final String? titleOverride;
  final ForegroundPlaybackState playback;
  final ValueChanged<MediaTrack> onPlay;

  @override
  Widget build(BuildContext context) {
    final title = titleOverride ?? playlist.title;
    final firstTrack = playlist.tracks.isEmpty ? null : playlist.tracks.first;
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
          Text(
            '歌单 · ${playlist.creatorName}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppTokens.space8),
          Text(title, style: Theme.of(context).textTheme.displaySmall),
          if (playlist.description.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppTokens.space8),
            Text(
              playlist.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: AppTokens.space12),
          Text(
            '${playlist.creatorName} · ${playlist.trackCount} 首',
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
              if (firstTrack != null)
                ScopifyPlayButton(
                  key: const Key('playlist-play-button'),
                  isPlaying:
                      playback.isPlaying &&
                      playback.currentTrack?.id == firstTrack.id,
                  onPressed: () => onPlay(firstTrack),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space20),
          Text('曲目', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space8),
          if (playlist.tracks.isEmpty)
            Text(
              '这个歌单暂时没有可播放的曲目。',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            PlaylistTrackList(
              tracks: playlist.tracks,
              currentTrackId: playback.currentTrack?.id,
              onPlay: onPlay,
            ),
        ],
      ),
    );
  }
}
