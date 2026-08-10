import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailLayout(
      eyebrow: '设置',
      body: ListView(
        padding: const EdgeInsets.all(AppTokens.space16),
        children: <Widget>[
          Text('播放', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          const _SettingRow(
            icon: Icons.high_quality_rounded,
            title: '音质',
            subtitle: '高品质（Fixture）',
          ),
          const _SettingRow(
            icon: Icons.graphic_eq_rounded,
            title: '音量均衡',
            subtitle: '将在 Playback Module 接入',
          ),
          const SizedBox(height: AppTokens.space24),
          Text('界面', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          _SettingRow(
            icon: Icons.dark_mode_outlined,
            title: '深色主题',
            subtitle: 'M1 固定使用 Scopify 深色画布',
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          const _SettingRow(
            icon: Icons.language_rounded,
            title: '语言',
            subtitle: '简体中文',
          ),
          const SizedBox(height: AppTokens.space24),
          Text('网络', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: AppTokens.space8),
          const _SettingRow(
            icon: Icons.dns_outlined,
            title: '后端地址',
            subtitle: 'M2 接入 Endpoint Module 后可配置',
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceSoft,
      borderRadius: AppTokens.radiusMedium,
      child: ListTile(
        leading: Icon(icon, color: AppTokens.textSecondary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}
