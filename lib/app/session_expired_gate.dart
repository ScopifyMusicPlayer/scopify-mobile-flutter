import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';

class SessionExpiredGate extends ConsumerWidget {
  const SessionExpiredGate({
    required this.child,
    required this.onRelogin,
    super.key,
  });

  final Widget child;
  final VoidCallback onRelogin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpired = ref
        .watch(sessionControllerProvider)
        .when(
          data: (session) => session is ExpiredSession,
          loading: () => false,
          error: (_, _) => false,
        );

    return PopScope(
      canPop: !isExpired,
      child: Stack(
        children: <Widget>[
          child,
          if (isExpired) ...<Widget>[
            const Positioned.fill(
              child: ModalBarrier(dismissible: false, color: AppTokens.overlay),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTokens.space20),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Material(
                        key: const Key('session-expired-modal'),
                        color: AppTokens.surfaceRaised,
                        elevation: 16,
                        borderRadius: AppTokens.radiusLarge,
                        child: Padding(
                          padding: const EdgeInsets.all(AppTokens.space24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Icons.lock_clock_outlined,
                                color: AppTokens.warning,
                                size: 32,
                              ),
                              const SizedBox(height: AppTokens.space16),
                              Text(
                                '登录状态已过期',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: AppTokens.space8),
                              Text(
                                '账号凭证和本机账号缓存已清理。当前页面与播放不会中断，你可以重新扫码或以游客继续。',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppTokens.space24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  TextButton(
                                    key: const Key('session-continue-guest'),
                                    onPressed: () => ref
                                        .read(
                                          sessionControllerProvider.notifier,
                                        )
                                        .continueAsGuest(),
                                    child: const Text('以游客继续'),
                                  ),
                                  const SizedBox(width: AppTokens.space8),
                                  FilledButton(
                                    key: const Key('session-relogin'),
                                    onPressed: () {
                                      ref
                                          .read(
                                            sessionControllerProvider.notifier,
                                          )
                                          .continueAsGuest();
                                      onRelogin();
                                    },
                                    child: const Text('重新扫码'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
