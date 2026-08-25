import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_play_button.dart';
import 'package:scopify_mobile/components/shared/scopify_pill_button.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/modules/playback/foreground_playback_controller.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/recent_tracks_provider.dart';

class RecentPage extends ConsumerWidget {
  const RecentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref
        .watch(sessionControllerProvider)
        .when(
          data: (value) => value,
          loading: () => null,
          error: (_, _) => null,
        );
    if (session is! AuthenticatedSession) {
      return DetailLayout(
        eyebrow: '最近播放',
        body: Center(
          child: ScopifyPillButton(
            onPressed: () => const QrLoginRoute().push(context),
            icon: Icons.qr_code_scanner_rounded,
            label: '扫码登录后查看最近播放',
          ),
        ),
      );
    }

    final playback = ref.watch(foregroundPlaybackProvider);
    return ref
        .watch(recentTracksProvider)
        .when(
          loading: () =>
              const DetailLayout(eyebrow: '最近播放', body: ScopifyLoadingState()),
          error: (_, _) => DetailLayout(
            eyebrow: '最近播放',
            body: ScopifyErrorState(
              title: '最近播放暂时没有加载出来',
              description: '请检查网络和登录状态后重试。',
              onRetry: () => ref.invalidate(recentTracksProvider),
            ),
          ),
          data: (tracks) => _RecentTrackData(
            tracks: tracks,
            playback: playback,
            onPlay: (track) => ref
                .read(foregroundPlaybackProvider.notifier)
                .playQueue(
                  tracks.map((item) => item.track).toList(growable: false),
                  startIndex: tracks.indexOf(track),
                ),
          ),
        );
  }
}

class _RecentTrackData extends StatelessWidget {
  const _RecentTrackData({
    required this.tracks,
    required this.playback,
    required this.onPlay,
  });

  final List<RecentTrack> tracks;
  final ForegroundPlaybackState playback;
  final ValueChanged<RecentTrack> onPlay;

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      eyebrow: '最近播放',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.space16,
          AppTokens.space8,
          AppTokens.space16,
          AppTokens.space32,
        ),
        children: <Widget>[
          Text('最近播放', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppTokens.space8),
          Text(
            '只显示最近听过的歌曲，不会修改服务端歌单。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space20),
          if (tracks.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: ScopifyPlayButton(
                isPlaying:
                    playback.isPlaying &&
                    playback.currentTrack?.id == tracks.first.track.id,
                onPressed: () => onPlay(tracks.first),
              ),
            ),
          const SizedBox(height: AppTokens.space12),
          if (tracks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space24),
              child: Text(
                '这里还没有最近播放记录。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...tracks.indexed.map(
              (entry) => _RecentTrackRow(
                index: entry.$1,
                recentTrack: entry.$2,
                isCurrent: playback.currentTrack?.id == entry.$2.track.id,
                onTap: () => onPlay(entry.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentTrackRow extends StatelessWidget {
  const _RecentTrackRow({
    required this.index,
    required this.recentTrack,
    required this.isCurrent,
    required this.onTap,
  });

  final int index;
  final RecentTrack recentTrack;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = recentTrack.track;
    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radiusMedium,
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
                  color: isCurrent ? AppTokens.accent : AppTokens.textTertiary,
                ),
              ),
            ),
            const SizedBox(width: AppTokens.space8),
            SizedBox(width: 48, child: MediaArtwork(seed: track.artworkSeed)),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${track.artist} · ${_playedAtLabel(recentTrack.playedAt)}',
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
          ],
        ),
      ),
    );
  }
}

String _playedAtLabel(DateTime? time) {
  if (time == null) return '刚刚播放';
  final elapsed = DateTime.now().difference(time);
  if (elapsed.inMinutes < 1) return '刚刚播放';
  if (elapsed.inHours < 1) return '${elapsed.inMinutes} 分钟前';
  if (elapsed.inDays < 1) return '${elapsed.inHours} 小时前';
  return '${elapsed.inDays} 天前';
}
