import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/fixture_state_view.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_media_list_tile.dart';
import 'package:scopify_mobile/components/shared/scopify_pill_button.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/providers/account_overview_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
        eyebrow: '个人资料',
        body: _ProfileLoginGate(
          onLogin: () => const QrLoginRoute().push(context),
        ),
      );
    }

    return ref
        .watch(accountOverviewProvider)
        .when(
          loading: () =>
              const DetailLayout(eyebrow: '个人资料', body: ScopifyLoadingState()),
          error: (_, _) => DetailLayout(
            eyebrow: '个人资料',
            body: ScopifyErrorState(
              title: '个人资料暂时没有加载出来',
              description: '请检查网络和登录状态后重试。',
              onRetry: () => ref.invalidate(accountOverviewProvider),
            ),
          ),
          data: (overview) => _ProfileData(overview: overview),
        );
  }
}

class _ProfileData extends StatelessWidget {
  const _ProfileData({required this.overview});

  final AccountOverview overview;

  @override
  Widget build(BuildContext context) {
    final profile = overview.profile;
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
                seed: profile.avatarUrl.isEmpty
                    ? profile.userId.toString()
                    : profile.avatarUrl,
                circular: true,
                shadow: true,
                semanticLabel: '${profile.nickname} 的头像',
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space20),
          Text(
            profile.nickname,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppTokens.space8),
          Text(
            profile.signature.isEmpty ? '这个人还没有留下签名。' : profile.signature,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTokens.space16),
          Row(
            children: <Widget>[
              _ProfileStat(value: '${profile.followingCount}', label: '关注'),
              _ProfileStat(value: '${profile.followerCount}', label: '粉丝'),
              _ProfileStat(value: '${profile.playlistCount}', label: '歌单'),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          Center(
            child: Text(
              'Lv.${profile.level} · 已听 ${profile.listenSongs} 首',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          Text('我的歌单', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space12),
          if (overview.playlists.isEmpty)
            Text('暂时没有可展示的歌单。', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...overview.playlists.map(
              (playlist) => ScopifyMediaListTile(
                title: playlist.name,
                subtitle: '${playlist.creatorName} · ${playlist.trackCount} 首',
                artworkSeed: playlist.id,
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTokens.textTertiary,
                ),
                onTap: () =>
                    HomePlaylistRoute(playlistId: playlist.id).push(context),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileLoginGate extends StatelessWidget {
  const _ProfileLoginGate({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.person_outline_rounded, size: 48),
            const SizedBox(height: AppTokens.space16),
            Text('登录后查看个人资料', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppTokens.space8),
            ScopifyPillButton(onPressed: onLogin, label: '扫码登录'),
          ],
        ),
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
