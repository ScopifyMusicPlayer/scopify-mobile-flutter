import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/layouts/modal_layout.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 332,
      backgroundColor: AppTokens.surfaceDeep,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  key: const Key('app-drawer-scroll'),
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    InkWell(
                      borderRadius: AppTokens.radiusMedium,
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => const ProfileRoute().push(hostContext),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 46,
                            child: MediaArtwork(
                              seed: 'momo-profile',
                              circular: true,
                            ),
                          ),
                          const SizedBox(width: AppTokens.space12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Momo Super Cool',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '查看个人资料',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppTokens.textTertiary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.space20),
                    _VipSignCard(
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => _showVipSign(hostContext),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space16),
                    _DrawerItem(
                      icon: Icons.radar_rounded,
                      title: '听歌识曲',
                      subtitle: '识别身边正在播放的音乐',
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => _showRecognition(hostContext),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.history_rounded,
                      title: '最近播放',
                      subtitle: '以歌单结构查看最近的声音',
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => const RecentRoute().push(hostContext),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.nightlight_round,
                      title: '睡眠定时',
                      subtitle: '与播放器使用同一个定时入口',
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => _showSleepTimer(hostContext),
                      ),
                    ),
                    const Divider(height: AppTokens.space32),
                    _DrawerItem(
                      icon: Icons.system_update_alt_rounded,
                      title: '检查更新',
                      subtitle: 'GitHub Releases · v0.1.0',
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => _showUpdate(hostContext),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: '设置',
                      subtitle: '播放、界面与网络',
                      onTap: () => _closeThen(
                        context,
                        (hostContext) =>
                            const SettingsRoute().push(hostContext),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space24),
                    Center(
                      child: Text(
                        'Scopify Mobile · M1 Fixture',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VipSignCard extends StatelessWidget {
  const _VipSignCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: AppTokens.radiusMedium,
      clipBehavior: Clip.antiAlias,
      color: AppTokens.surfaceCard,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTokens.space16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF285946), Color(0xFF182E29)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('网易乐签', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppTokens.space4),
              Text(
                '今日未签 · 点亮今天的音乐感受',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppTokens.space12),
              Text('连续签到 5 天', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.space4),
      leading: Icon(icon, color: AppTokens.textSecondary),
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTokens.textTertiary,
      ),
      onTap: onTap,
    );
  }
}

void _closeThen(
  BuildContext context,
  void Function(BuildContext hostContext) action,
) {
  final navigator = Navigator.of(context);
  final hostContext = navigator.context;
  navigator.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (hostContext.mounted) action(hostContext);
  });
}

void _showVipSign(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: AppTokens.overlay,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppTokens.space20),
      child: ModalLayout(
        title: '网易乐签',
        subtitle: '今天的音乐从一张小签开始。',
        onClose: () => Navigator.of(dialogContext).pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '08',
                  style: Theme.of(dialogContext).textTheme.displaySmall,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space8,
                  ),
                  child: Text(
                    '/',
                    style: Theme.of(dialogContext).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '10',
                  style: Theme.of(dialogContext).textTheme.displaySmall,
                ),
                const Spacer(),
                SizedBox(width: 72, child: MediaArtwork(seed: 'vip-sign')),
              ],
            ),
            const SizedBox(height: AppTokens.space16),
            Text(
              'From The Start',
              style: Theme.of(dialogContext).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              '让今天从一首愿意反复听的歌开始。',
              style: Theme.of(dialogContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppTokens.space20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('乐签已在 Fixture 中点亮。')),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('点亮乐签'),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showSleepTimer(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space12),
        child: ModalLayout(
          title: '睡眠定时',
          subtitle: 'Drawer 和播放器都会打开这个同一入口。',
          onClose: () => Navigator.of(sheetContext).pop(),
          child: Column(
            children: <Widget>[
              for (final label in <String>[
                '未开启',
                '当前歌曲结束后',
                '15 分钟后',
                '30 分钟后',
                '45 分钟后',
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  trailing: label == '未开启'
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppTokens.accent,
                        )
                      : const Icon(Icons.radio_button_unchecked_rounded),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showRecognition(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space12),
        child: ModalLayout(
          title: '听歌识曲',
          subtitle: 'M1 只展示流程，稍后由 Recognition Module 请求麦克风权限。',
          onClose: () => Navigator.of(sheetContext).pop(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.mic_none_rounded,
                size: 42,
                color: AppTokens.accent,
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                '准备好后开始聆听',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                '不会上传原始录音；权限和识别结果会在真实模块中单独管理。',
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppTokens.space20),
              FilledButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('识曲能力将在 M3 后接入。')),
                  );
                },
                child: const Text('开始识别'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showUpdate(BuildContext context) {
  showDialog<void>(
    context: context,
    barrierColor: AppTokens.overlay,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppTokens.space20),
      child: ModalLayout(
        title: '检查更新',
        subtitle: '更新信息将来自 GitHub Releases。',
        onClose: () => Navigator.of(dialogContext).pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _VersionLine(label: '当前版本', value: 'v0.1.0'),
            const SizedBox(height: AppTokens.space12),
            _VersionLine(label: '最新版本', value: '等待 GitHub Releases 查询'),
            const SizedBox(height: AppTokens.space20),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('M1 不执行网络检查。'))),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('模拟检查'),
            ),
          ],
        ),
      ),
    ),
  );
}

class _VersionLine extends StatelessWidget {
  const _VersionLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
