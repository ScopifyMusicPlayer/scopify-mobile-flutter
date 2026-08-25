import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_controller.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_state.dart';

class QrLoginPage extends ConsumerStatefulWidget {
  const QrLoginPage({super.key});

  @override
  ConsumerState<QrLoginPage> createState() => _QrLoginPageState();
}

class _QrLoginPageState extends ConsumerState<QrLoginPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(qrLoginControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(qrLoginControllerProvider, (previous, next) {
      if (previous?.phase == QrLoginPhase.success ||
          next.phase != QrLoginPhase.success) {
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.canPop()) context.pop(true);
      });
    });

    final state = ref.watch(qrLoginControllerProvider);
    return Scaffold(
      key: const Key('qr-login-page'),
      backgroundColor: AppTokens.canvas,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 56,
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: '关闭扫码登录',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '扫码登录',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final qrSize = math.min(240.0, constraints.maxWidth - 64);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTokens.space24,
                      AppTokens.space16,
                      AppTokens.space24,
                      AppTokens.space24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(0, constraints.maxHeight - 40),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox.shrink(),
                          Column(
                            children: <Widget>[
                              _QrSurface(
                                state: state,
                                size: qrSize,
                                onRefresh: () => ref
                                    .read(qrLoginControllerProvider.notifier)
                                    .refresh(),
                              ),
                              const SizedBox(height: AppTokens.space20),
                              Text(
                                state.statusText,
                                key: const Key('qr-login-status'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: switch (state.phase) {
                                        QrLoginPhase.success =>
                                          AppTokens.accent,
                                        QrLoginPhase.expired =>
                                          AppTokens.danger,
                                        _ => AppTokens.textPrimary,
                                      },
                                    ),
                              ),
                              const SizedBox(height: AppTokens.space8),
                              Text(
                                '使用 网易云音乐 App 扫码',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const _ScreenshotHint(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrSurface extends StatelessWidget {
  const _QrSurface({
    required this.state,
    required this.size,
    required this.onRefresh,
  });

  final QrLoginState state;
  final double size;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final image = _decodeQrImage(state.qrImageDataUri);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(AppTokens.space12),
      decoration: const BoxDecoration(
        color: AppTokens.textPrimary,
        borderRadius: AppTokens.radiusLarge,
        boxShadow: AppTokens.floatingShadow,
      ),
      child: ClipRRect(
        borderRadius: AppTokens.radiusMedium,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (image == null)
              const ColoredBox(
                color: AppTokens.textPrimary,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppTokens.surfaceBase,
                  ),
                ),
              )
            else
              Image.memory(
                image,
                key: const Key('qr-login-image'),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            if (state.phase == QrLoginPhase.scanned)
              const ColoredBox(
                color: Color(0x99000000),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTokens.space16),
                    child: Text(
                      '请在手机上确认',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            if (state.phase == QrLoginPhase.expired)
              ColoredBox(
                color: AppTokens.overlay,
                child: Center(
                  child: FilledButton.tonalIcon(
                    key: const Key('qr-login-refresh'),
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('刷新二维码'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScreenshotHint extends StatelessWidget {
  const _ScreenshotHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            color: AppTokens.textTertiary,
            size: 18,
          ),
          const SizedBox(width: AppTokens.space8),
          Flexible(
            child: Text(
              '你也可以截图或保存二维码，再用另一台设备完成扫码。本 App 只提供二维码登录。',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

Uint8List? _decodeQrImage(String? dataUri) {
  if (dataUri == null || dataUri.isEmpty) return null;
  try {
    return base64Decode(
      dataUri.contains(',') ? dataUri.split(',').last : dataUri,
    );
  } on FormatException {
    return null;
  }
}
