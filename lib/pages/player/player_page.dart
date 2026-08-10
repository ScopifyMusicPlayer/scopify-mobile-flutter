import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/components/shared/scopify_play_button.dart';
import 'package:scopify_mobile/layouts/player_layout.dart';
import 'package:scopify_mobile/modules/playback/foreground_playback_controller.dart';
import 'package:scopify_mobile/pages/player/components/player_center.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(foregroundPlaybackProvider);
    final track = playback.currentTrack ?? demoTrack;
    final controller = ref.read(foregroundPlaybackProvider.notifier);
    final duration = playback.duration == Duration.zero
        ? track.duration
        : playback.duration;
    final position = playback.position > duration
        ? duration
        : playback.position;
    final progress = duration == Duration.zero
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    void announce(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return PlayerLayout(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    tooltip: '收起播放器',
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(
                          '正在播放',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          track.album,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  ScopifyIconAction(
                    icon: Icons.more_horiz_rounded,
                    tooltip: '更多播放选项',
                    onPressed: () => announce('播放选项会在后续接入。'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space20,
                ),
                child: PlayerCenter(
                  track: track,
                  isPlaying: playback.isPlaying,
                  showsLyrics: playback.showsLyrics,
                  lyrics: playback.lyrics,
                  position: position,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space20,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppTokens.space4),
                        Text(
                          track.artist,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  ScopifyIconAction(
                    icon: Icons.favorite_border_rounded,
                    tooltip: '喜欢',
                    onPressed: () => announce('喜欢功能将在登录后接入。'),
                  ),
                ],
              ),
            ),
            Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: duration == Duration.zero
                  ? null
                  : (value) => controller.seek(
                      Duration(
                        milliseconds: (duration.inMilliseconds * value).round(),
                      ),
                    ),
              activeColor: AppTokens.textPrimary,
              inactiveColor: AppTokens.surfaceInteractive,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    _durationLabel(position),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    _durationLabel(duration),
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space20,
                AppTokens.space8,
                AppTokens.space20,
                AppTokens.space16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ScopifyIconAction(
                    icon: Icons.shuffle_rounded,
                    tooltip: '随机播放',
                    active: playback.shuffleEnabled,
                    onPressed: controller.toggleShuffle,
                  ),
                  ScopifyIconAction(
                    icon: Icons.skip_previous_rounded,
                    tooltip: '上一首',
                    onPressed: controller.previous,
                  ),
                  ScopifyPlayButton(
                    isPlaying: playback.isPlaying,
                    darkIcon: false,
                    onPressed: () => controller.toggle(demoTrack),
                  ),
                  ScopifyIconAction(
                    icon: Icons.skip_next_rounded,
                    tooltip: '下一首',
                    onPressed: controller.next,
                  ),
                  ScopifyIconAction(
                    icon: playback.showsLyrics
                        ? Icons.album_outlined
                        : Icons.lyrics_outlined,
                    tooltip: playback.showsLyrics ? '切换到唱片' : '切换到歌词',
                    active: playback.showsLyrics,
                    onPressed: controller.toggleLyrics,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () =>
                        announce('当前队列 ${playback.queue.length} 首。'),
                    icon: const Icon(Icons.queue_music_rounded),
                    label: const Text('队列'),
                  ),
                  TextButton.icon(
                    onPressed: controller.cycleRepeatMode,
                    icon: Icon(_repeatIcon(playback.repeatMode)),
                    label: Text(_repeatLabel(playback.repeatMode)),
                  ),
                  TextButton.icon(
                    onPressed: () => announce('歌曲评论入口已预留。'),
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('评论'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _durationLabel(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

IconData _repeatIcon(PlaybackRepeatMode mode) => mode == PlaybackRepeatMode.one
    ? Icons.repeat_one_rounded
    : Icons.repeat_rounded;

String _repeatLabel(PlaybackRepeatMode mode) => switch (mode) {
  PlaybackRepeatMode.off => '不循环',
  PlaybackRepeatMode.all => '列表循环',
  PlaybackRepeatMode.one => '单曲循环',
};
