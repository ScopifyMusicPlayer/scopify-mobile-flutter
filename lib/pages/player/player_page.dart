import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/scopify_icon_action.dart';
import 'package:scopify_mobile/components/shared/scopify_play_button.dart';
import 'package:scopify_mobile/layouts/player_layout.dart';
import 'package:scopify_mobile/modules/playback/fake_playback_controller.dart';
import 'package:scopify_mobile/pages/player/components/player_center.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(fakePlaybackProvider);
    final track = playback.currentTrack ?? demoTrack;
    final controller = ref.read(fakePlaybackProvider.notifier);

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
              value: 0.38,
              onChanged: (_) {},
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
                  Text('1:09', style: Theme.of(context).textTheme.labelMedium),
                  Text(
                    track.durationLabel,
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
                    active: true,
                    onPressed: () => announce('随机播放将在真实队列中生效。'),
                  ),
                  ScopifyIconAction(
                    icon: Icons.skip_previous_rounded,
                    tooltip: '上一首',
                    onPressed: () => announce('Fake Playback 暂无上一首。'),
                  ),
                  ScopifyPlayButton(
                    isPlaying: playback.isPlaying,
                    darkIcon: false,
                    onPressed: () => controller.toggle(demoTrack),
                  ),
                  ScopifyIconAction(
                    icon: Icons.skip_next_rounded,
                    tooltip: '下一首',
                    onPressed: () => announce('Fake Playback 暂无下一首。'),
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
                    onPressed: () => announce('播放队列入口已预留。'),
                    icon: const Icon(Icons.queue_music_rounded),
                    label: const Text('队列'),
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
