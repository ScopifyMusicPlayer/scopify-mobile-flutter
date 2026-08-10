import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/layouts/detail_layout.dart';
import 'package:scopify_mobile/layouts/modal_layout.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_store.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final endpoint = ref.watch(backendEndpointControllerProvider);
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
          _SettingRow(
            icon: Icons.dns_outlined,
            title: '后端地址',
            subtitle: endpoint.when(
              data: (value) => value.baseUrl,
              loading: () => '正在读取后端设置…',
              error: (_, _) => '后端设置读取失败，点击重新配置',
            ),
            onTap: () => showDialog<void>(
              context: context,
              barrierColor: AppTokens.overlay,
              builder: (_) => _EndpointEditor(
                initialEndpoint: endpoint.when(
                  data: (value) => value,
                  loading: () => BackendEndpoint.defaultValue,
                  error: (_, _) => BackendEndpoint.defaultValue,
                ),
              ),
            ),
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

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
        onTap: onTap,
      ),
    );
  }
}

class _EndpointEditor extends ConsumerStatefulWidget {
  const _EndpointEditor({required this.initialEndpoint});

  final BackendEndpoint initialEndpoint;

  @override
  ConsumerState<_EndpointEditor> createState() => _EndpointEditorState();
}

class _EndpointEditorState extends ConsumerState<_EndpointEditor> {
  late final TextEditingController _controller;
  EndpointProbeResult? _probeResult;
  String? _errorMessage;
  bool _isProbing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEndpoint.baseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _probe() async {
    setState(() {
      _isProbing = true;
      _probeResult = null;
      _errorMessage = null;
    });
    try {
      final result = await ref
          .read(backendEndpointControllerProvider.notifier)
          .probe(_controller.text);
      if (!mounted) return;
      setState(() => _probeResult = result);
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isProbing = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref
          .read(backendEndpointControllerProvider.notifier)
          .save(_controller.text);
      if (mounted) Navigator.of(context).pop();
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _probeResult;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppTokens.space20),
      child: ModalLayout(
        title: '后端地址',
        subtitle: '公网地址必须使用 HTTPS；HTTP 仅用于本机或私有网络。',
        onClose: () => Navigator.of(context).pop(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'HTTP / HTTPS 地址',
                hintText: 'http://10.0.2.2:3838',
              ),
            ),
            const SizedBox(height: AppTokens.space12),
            Text(
              '模拟器访问本机服务时使用 10.0.2.2；真机请填写局域网 IP。',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            if (_errorMessage != null) ...<Widget>[
              const SizedBox(height: AppTokens.space12),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            if (result != null) ...<Widget>[
              const SizedBox(height: AppTokens.space12),
              _ProbeResultView(result: result),
            ],
            const SizedBox(height: AppTokens.space20),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProbing || _isSaving ? null : _probe,
                    icon: _isProbing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.wifi_find_rounded),
                    label: const Text('连接探测'),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving || _isProbing ? null : _save,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('保存地址'),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _isSaving || _isProbing ? null : _restoreDefault,
              child: const Text('恢复模拟器默认地址'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restoreDefault() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _probeResult = null;
    });
    try {
      await ref
          .read(backendEndpointControllerProvider.notifier)
          .restoreDefault();
      if (!mounted) return;
      _controller.text = BackendEndpoint.defaultValue.baseUrl;
      setState(() {});
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _ProbeResultView extends StatelessWidget {
  const _ProbeResultView({required this.result});

  final EndpointProbeResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.isReachable
        ? AppTokens.accent
        : Theme.of(context).colorScheme.error;
    return Row(
      children: <Widget>[
        Icon(
          result.isReachable
              ? Icons.check_circle_outline_rounded
              : Icons.error_outline_rounded,
          color: color,
        ),
        const SizedBox(width: AppTokens.space8),
        Expanded(
          child: Text(
            result.isReachable
                ? '连接正常 · ${result.elapsed.inMilliseconds} ms'
                : result.message ?? '连接失败',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
