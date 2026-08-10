import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      eyebrow: '个人资料',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTokens.space16,
          AppTokens.space16,
          AppTokens.space16,
          AppTokens.space32,
        ),
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 132,
              child: MediaArtwork(
                seed: 'momo-profile',
                circular: true,
                shadow: true,
                semanticLabel: 'Momo Super Cool 的头像',
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space20),
          Text(
            'Momo Super Cool',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppTokens.space8),
          Text('今天也把喜欢的音乐留给自己。', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppTokens.space16),
          Row(
            children: <Widget>[
              _ProfileStat(value: '12', label: '关注'),
              _ProfileStat(value: '34', label: '粉丝'),
              _ProfileStat(value: '18', label: '歌单'),
            ],
          ),
          const SizedBox(height: AppTokens.space24),
          Text('公开歌单', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space12),
          ...playlistFixtures
              .take(2)
              .map(
                (playlist) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 54,
                    child: MediaArtwork(seed: playlist.artworkSeed),
                  ),
                  title: Text(playlist.title),
                  subtitle: Text(playlist.subtitle),
                ),
              ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
