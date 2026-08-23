import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_api.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_state.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

part 'qr_login_controller.g.dart';

final qrPollingDelayProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => Future<void>.delayed(const Duration(seconds: 3)),
);

@riverpod
class QrLoginController extends _$QrLoginController {
  int _generation = 0;

  @override
  QrLoginState build() {
    ref.onDispose(() => _generation++);
    return const QrLoginState.loading();
  }

  Future<void> start() async {
    final generation = ++_generation;
    state = const QrLoginState.loading();

    try {
      final api = ref.read(qrLoginApiProvider);
      final key = await api.requestKey();
      if (!_isCurrent(generation)) return;

      final image = await api.create(key.value);
      if (!_isCurrent(generation)) return;
      state = QrLoginState(
        phase: QrLoginPhase.waiting,
        statusText: '打开 App 扫一扫登录',
        qrImageDataUri: image.dataUri,
      );

      while (_isCurrent(generation)) {
        final check = await api.check(key.value);
        if (!_isCurrent(generation)) return;

        switch (check.code) {
          case 800:
            state = state.copyWith(
              phase: QrLoginPhase.expired,
              statusText: '二维码已过期',
            );
            return;
          case 801:
            state = state.copyWith(
              phase: QrLoginPhase.waiting,
              statusText: '打开 App 扫一扫登录',
            );
            break;
          case 802:
            state = state.copyWith(
              phase: QrLoginPhase.scanned,
              statusText: '已扫码，请在手机上确认',
            );
            break;
          case 803:
            final cookie = check.cookie;
            if (cookie == null || cookie.isEmpty) {
              throw AppFailure.business(message: '扫码成功，但后端没有返回登录凭据。');
            }
            await ref.read(sessionControllerProvider.future);
            await ref
                .read(sessionControllerProvider.notifier)
                .establish(cookie, shouldCommit: () => _isCurrent(generation));
            if (!_isCurrent(generation)) return;
            state = state.copyWith(
              phase: QrLoginPhase.success,
              statusText: '授权登录成功！',
            );
            return;
          default:
            throw AppFailure.business(message: '后端返回了无法识别的扫码状态。');
        }

        await ref.read(qrPollingDelayProvider)();
      }
    } catch (error) {
      if (!_isCurrent(generation)) return;
      state = state.copyWith(
        phase: QrLoginPhase.expired,
        statusText: error is AppFailure ? error.message : '网络请求失败，请刷新二维码',
      );
    }
  }

  Future<void> refresh() => start();

  bool _isCurrent(int generation) => generation == _generation;
}
