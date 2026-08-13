import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

/// The logged-out presentation of My keeps the destination's structure
/// visible without requesting any account-scoped data.
class MyGuestHub extends StatelessWidget {
  const MyGuestHub({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: <Widget>[
          _GuestProfileHeader(onLogin: onLogin),
          const TabBar(
            tabs: <Widget>[
              Tab(text: '音乐'),
              Tab(text: '播客'),
              Tab(text: '收藏'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _MyLoginGate(
                  icon: Icons.library_music_outlined,
                  title: '登录后查看你的音乐与歌单',
                  description: '同步我喜欢的音乐、创建和收藏的歌单。',
                  onLogin: onLogin,
                ),
                _MyLoginGate(
                  icon: Icons.podcasts_outlined,
                  title: '登录后查看订阅的播客',
                  description: '同步已订阅的播客、创建的声音单和喜欢的声音。',
                  onLogin: onLogin,
                ),
                _MyLoginGate(
                  icon: Icons.favorite_border_rounded,
                  title: '登录后查看关注与收藏',
                  description: '同步关注的歌手和收藏的专辑。',
                  onLogin: onLogin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestProfileHeader extends StatelessWidget {
  const _GuestProfileHeader({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space12,
        AppTokens.space16,
        AppTokens.space16,
      ),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 34,
            backgroundColor: AppTokens.surfaceRaised,
            child: Icon(
              Icons.person_outline_rounded,
              color: AppTokens.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '登录后同步你的音乐库',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  '歌单、最近播放与收藏都会保留在这里。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTokens.space12),
                FilledButton.icon(
                  onPressed: onLogin,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('扫码登录'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLoginGate extends StatelessWidget {
  const _MyLoginGate({
    required this.icon,
    required this.title,
    required this.description,
    required this.onLogin,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.space16),
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: AppTokens.surfaceCard,
            borderRadius: AppTokens.radiusLarge,
          ),
          padding: const EdgeInsets.all(AppTokens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: AppTokens.textSecondary, size: 30),
              const SizedBox(height: AppTokens.space16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTokens.space8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppTokens.space20),
              FilledButton(
                onPressed: onLogin,
                child: const Text('使用网易云音乐扫码登录'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
