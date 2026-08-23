import 'dart:collection';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_api.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_controller.dart';
import 'package:scopify_mobile/modules/qr_login/qr_login_state.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';

import '../../support/session_fakes.dart';

class _SequenceQrLoginGateway implements QrLoginGateway {
  _SequenceQrLoginGateway(Iterable<QrLoginCheck> checks)
    : _checks = Queue<QrLoginCheck>.of(checks);

  final Queue<QrLoginCheck> _checks;

  @override
  Future<QrLoginCheck> check(String key) async => _checks.removeFirst();

  @override
  Future<QrLoginImage> create(String key) async =>
      const QrLoginImage('data:image/png;base64,AA==');

  @override
  Future<QrLoginKey> requestKey() async => const QrLoginKey('qr-key');
}

class _RestartQrLoginGateway implements QrLoginGateway {
  final firstKey = Completer<QrLoginKey>();
  int keyRequests = 0;
  final List<String> createdKeys = <String>[];

  @override
  Future<QrLoginKey> requestKey() {
    keyRequests++;
    return keyRequests == 1
        ? firstKey.future
        : Future<QrLoginKey>.value(const QrLoginKey('new-key'));
  }

  @override
  Future<QrLoginImage> create(String key) async {
    createdKeys.add(key);
    return const QrLoginImage('data:image/png;base64,AA==');
  }

  @override
  Future<QrLoginCheck> check(String key) async => const QrLoginCheck(code: 800);
}

class _PendingSessionGateway implements SessionGateway {
  final validationStarted = Completer<void>();
  final validationResult = Completer<SessionProfile>();

  @override
  String get endpointId => 'http://10.0.2.2:3838';

  @override
  Future<void> revokeCredential(String cookie) async {}

  @override
  Future<SessionProfile> validateCredential(String cookie) {
    if (!validationStarted.isCompleted) validationStarted.complete();
    return validationResult.future;
  }
}

void main() {
  test('moves through scan states and establishes the session', () async {
    final store = MemoryCredentialStore();
    final sessionApi = FakeSessionGateway();
    final qrApi = _SequenceQrLoginGateway(const <QrLoginCheck>[
      QrLoginCheck(code: 801),
      QrLoginCheck(code: 802),
      QrLoginCheck(code: 803, cookie: 'qr-cookie'),
    ]);
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(sessionApi),
        qrLoginApiProvider.overrideWithValue(qrApi),
        qrPollingDelayProvider.overrideWithValue(() async {}),
      ],
    );
    final phases = <QrLoginPhase>[];
    final subscription = container.listen(
      qrLoginControllerProvider,
      (_, next) => phases.add(next.phase),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(qrLoginControllerProvider.notifier).start();

    expect(
      phases,
      containsAllInOrder(<QrLoginPhase>[
        QrLoginPhase.loading,
        QrLoginPhase.waiting,
        QrLoginPhase.scanned,
        QrLoginPhase.success,
      ]),
    );
    expect(store.credential?.cookie, 'qr-cookie');
    final session = await container.read(sessionControllerProvider.future);
    expect(session, isA<AuthenticatedSession>());
  });

  test('exposes an expired state that can be refreshed', () async {
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
        sessionApiProvider.overrideWithValue(FakeSessionGateway()),
        qrLoginApiProvider.overrideWithValue(
          _SequenceQrLoginGateway(const <QrLoginCheck>[
            QrLoginCheck(code: 800),
          ]),
        ),
      ],
    );
    final subscription = container.listen(qrLoginControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    await container.read(qrLoginControllerProvider.notifier).start();

    final state = container.read(qrLoginControllerProvider);
    expect(state.phase, QrLoginPhase.expired);
    expect(state.statusText, '二维码已过期');
  });

  test('ignores results from a replaced login key', () async {
    final qrApi = _RestartQrLoginGateway();
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
        sessionApiProvider.overrideWithValue(FakeSessionGateway()),
        qrLoginApiProvider.overrideWithValue(qrApi),
      ],
    );
    final subscription = container.listen(qrLoginControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    final firstFlow = container
        .read(qrLoginControllerProvider.notifier)
        .start();
    await Future<void>.delayed(Duration.zero);
    await container.read(qrLoginControllerProvider.notifier).refresh();
    qrApi.firstKey.complete(const QrLoginKey('old-key'));
    await firstFlow;

    expect(qrApi.createdKeys, <String>['new-key']);
    expect(
      container.read(qrLoginControllerProvider).phase,
      QrLoginPhase.expired,
    );
  });

  test('does not persist a session after the login flow is disposed', () async {
    final store = MemoryCredentialStore();
    final sessionApi = _PendingSessionGateway();
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(sessionApi),
        qrLoginApiProvider.overrideWithValue(
          _SequenceQrLoginGateway(const <QrLoginCheck>[
            QrLoginCheck(code: 803, cookie: 'late-cookie'),
          ]),
        ),
      ],
    );
    final subscription = container.listen(qrLoginControllerProvider, (_, _) {});
    final flow = container.read(qrLoginControllerProvider.notifier).start();
    await sessionApi.validationStarted.future;

    subscription.close();
    await Future<void>.delayed(Duration.zero);
    sessionApi.validationResult.complete(
      const SessionProfile(
        userId: 42,
        nickname: '迟到结果',
        avatarUrl: '',
        signature: '',
      ),
    );
    await flow;

    expect(store.credential, isNull);
  });
}
