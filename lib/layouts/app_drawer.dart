import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/router/app_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/components/shared/scopify_pill_button.dart';
import 'package:scopify_mobile/layouts/modal_layout.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/providers/vip_sign_provider.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref
        .watch(sessionControllerProvider)
        .when(
          data: (value) => value,
          loading: () => const GuestSession(),
          error: (_, _) => const GuestSession(),
        );
    final profile = session is AuthenticatedSession ? session.profile : null;
    final signOut = ref.read(sessionControllerProvider.notifier).signOut;
    final signToday = ref.read(vipSignActionProvider.notifier).signToday;
    final vipSignState = profile == null
        ? null
        : ref.watch(vipSignHistoryProvider);
    final vipHistory = vipSignState?.when(
      data: (value) => value,
      loading: () => null,
      error: (_, _) => null,
    );

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
                    _AccountHeader(
                      profile: profile,
                      onTap: () => _closeThen(
                        context,
                        (hostContext) => profile == null
                            ? const QrLoginRoute().push(hostContext)
                            : const ProfileRoute().push(hostContext),
                      ),
                    ),
                    const SizedBox(height: AppTokens.space20),
                    _VipSignCard(
                      isGuest: profile == null,
                      history: vipHistory,
                      isLoading: vipSignState?.isLoading ?? false,
                      hasError: vipSignState?.hasError ?? false,
                      onTap: () => _closeThen(context, (hostContext) {
                        if (profile == null) {
                          const QrLoginRoute().push(hostContext);
                        } else if (vipSignState?.hasError == true) {
                          ref.invalidate(vipSignHistoryProvider);
                          ScaffoldMessenger.of(hostContext).showSnackBar(
                            const SnackBar(content: Text('正在重试读取今日乐签。')),
                          );
                        } else {
                          _showVipSign(
                            hostContext,
                            history:
                                ref
                                    .read(vipSignHistoryProvider)
                                    .when(
                                      data: (value) => value,
                                      loading: () => null,
                                      error: (_, _) => null,
                                    ) ??
                                vipHistory,
                            onSign: signToday,
                          );
                        }
                      }),
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
                    if (profile != null)
                      _DrawerItem(
                        icon: Icons.logout_rounded,
                        title: '退出账号',
                        subtitle: '清除本机登录状态与账号缓存',
                        onTap: () => _closeThen(
                          context,
                          (hostContext) =>
                              _showSignOutConfirmation(hostContext, signOut),
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

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.profile, required this.onTap});

  final SessionProfile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppTokens.radiusMedium,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space4),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 46,
              height: 46,
              child: profile == null
                  ? const CircleAvatar(
                      backgroundColor: AppTokens.surfaceRaised,
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppTokens.textSecondary,
                      ),
                    )
                  : MediaArtwork(seed: profile!.nickname, circular: true),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile?.nickname ?? '使用二维码登录',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile == null
                        ? '同步你的音乐库与收藏'
                        : profile!.signature.isEmpty
                        ? '查看个人资料'
                        : profile!.signature,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
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
    );
  }
}

class _VipSignCard extends StatelessWidget {
  const _VipSignCard({
    required this.isGuest,
    required this.history,
    required this.isLoading,
    required this.hasError,
    required this.onTap,
  });

  final bool isGuest;
  final VipSignHistory? history;
  final bool isLoading;
  final bool hasError;
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
                isGuest
                    ? '登录后查看今日乐签'
                    : isLoading
                    ? '正在读取今日乐签'
                    : hasError
                    ? '今日乐签暂不可用'
                    : history?.signedToday == true
                    ? '今日已签 · 查看今日乐签'
                    : '今日未签 · 查看签到状态',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                isGuest
                    ? '使用网易云音乐扫码登录'
                    : isLoading
                    ? '请稍候…'
                    : hasError
                    ? '点击重试读取'
                    : history?.subText.isNotEmpty == true
                    ? history!.subText
                    : '近 ${history?.signedDayCount ?? 0} 天有签到记录',
                style: Theme.of(context).textTheme.labelLarge,
              ),
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

void _showVipSign(
  BuildContext context, {
  VipSignHistory? history,
  Future<VipSignResult> Function()? onSign,
}) {
  final today = history?.today;
  showDialog<void>(
    context: context,
    barrierColor: AppTokens.overlay,
    builder: (dialogContext) {
      var isSigning = false;
      return StatefulBuilder(
        builder: (dialogContext, setState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppTokens.space20),
          child: ModalLayout(
            title: '网易乐签',
            subtitle: history == null
                ? '今日乐签暂时没有读取成功。'
                : today?.isSigned == true
                ? '今日已签，下面是当前签到状态。'
                : '今日尚未签到，确认后会同步到当前账号。',
            onClose: () => Navigator.of(dialogContext).pop(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      '${history?.signedDayCount ?? 0}',
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
                      '${history?.days.length ?? 0}',
                      style: Theme.of(dialogContext).textTheme.displaySmall,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 72,
                      child: MediaArtwork(
                        seed: today?.songCoverUrl.isNotEmpty == true
                            ? today!.songCoverUrl
                            : 'vip-sign',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space16),
                Text(
                  today?.isSigned == true ? '今日已签' : '今日乐签',
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  today?.isSigned == true
                      ? '签到记录已同步到当前账号。'
                      : '签到成功后会刷新今日状态，不会重复提交。',
                  style: Theme.of(dialogContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTokens.space20),
                ScopifyPillButton(
                  onPressed: history == null || today?.isSigned == true
                      ? () => Navigator.of(dialogContext).pop()
                      : () async {
                          if (onSign == null || isSigning) return;
                          setState(() => isSigning = true);
                          try {
                            final result = await onSign();
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result.message)),
                            );
                          } on Object {
                            if (!dialogContext.mounted) return;
                            setState(() => isSigning = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('签到失败，请稍后重试。')),
                            );
                          }
                        },
                  isLoading: isSigning,
                  icon: today?.isSigned == true
                      ? Icons.check_circle_outline_rounded
                      : Icons.check_rounded,
                  label: today?.isSigned == true ? '今日已签' : '今日签到',
                  variant: today?.isSigned == true
                      ? ScopifyPillButtonVariant.soft
                      : ScopifyPillButtonVariant.brand,
                ),
              ],
            ),
          ),
        ),
      );
    },
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

Future<void> _showSignOutConfirmation(
  BuildContext context,
  Future<void> Function() signOut,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: AppTokens.overlay,
    builder: (dialogContext) => AlertDialog(
      title: const Text('退出当前账号？'),
      content: const Text('本机会清除登录凭证与账号缓存，公共内容和当前播放不会受影响。'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          key: const Key('confirm-sign-out'),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('退出账号'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    await signOut();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已退出账号。')));
  } on Object {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('本机登录状态清理失败，请重试。')));
  }
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
