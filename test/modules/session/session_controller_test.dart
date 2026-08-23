import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_cache_cleanup.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_expiry_bus.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

import '../../support/session_fakes.dart';

void main() {
  test('restores a credential only for the current endpoint', () async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'music-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final api = FakeSessionGateway();
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(api),
      ],
    );

    final session = await container.read(sessionControllerProvider.future);

    expect(session, isA<AuthenticatedSession>());
    expect(api.validatedCookies, <String>['music-cookie']);
  });

  test('clears a credential saved for another endpoint', () async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'old-cookie',
        endpointId: 'https://old.example.com',
      ),
    );
    final api = FakeSessionGateway();
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(api),
      ],
    );

    final session = await container.read(sessionControllerProvider.future);

    expect(session, isA<GuestSession>());
    expect(store.credential, isNull);
    expect(api.validatedCookies, isEmpty);
  });

  test('clears a credential rejected by account validation', () async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'expired-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(
          FakeSessionGateway(error: AppFailure.business(message: '登录状态已失效。')),
        ),
      ],
    );

    final session = await container.read(sessionControllerProvider.future);

    expect(session, isA<GuestSession>());
    expect(store.credential, isNull);
  });

  test('signs out remotely and clears only the active account cache', () async {
    final store = MemoryCredentialStore(
      credential: const StoredSessionCredential(
        cookie: 'music-cookie',
        endpointId: 'http://10.0.2.2:3838',
      ),
    );
    final api = FakeSessionGateway();
    final clearedScopes = <String>[];

    Future<void> clearAccountCache({
      required String endpointId,
      required String accountId,
    }) async {
      clearedScopes.add('$endpointId|$accountId');
    }

    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(store),
        sessionApiProvider.overrideWithValue(api),
        accountCacheClearerProvider.overrideWithValue(clearAccountCache),
      ],
    );
    await container.read(sessionControllerProvider.future);

    await container.read(sessionControllerProvider.notifier).signOut();

    expect(api.revokedCookies, <String>['music-cookie']);
    expect(store.credential, isNull);
    expect(clearedScopes, <String>['http://10.0.2.2:3838|42']);
    expect(
      container.read(sessionControllerProvider).requireValue,
      isA<GuestSession>(),
    );
  });

  test(
    'turns an authenticated session into an expired decision state',
    () async {
      final store = MemoryCredentialStore(
        credential: const StoredSessionCredential(
          cookie: 'music-cookie',
          endpointId: 'http://10.0.2.2:3838',
        ),
      );
      final expiryBus = SessionExpiryBus();
      addTearDown(expiryBus.close);
      final clearedAccounts = <String>[];

      Future<void> clearAccountCache({
        required String endpointId,
        required String accountId,
      }) async {
        clearedAccounts.add(accountId);
      }

      final container = ProviderContainer.test(
        overrides: [
          credentialStoreProvider.overrideWithValue(store),
          sessionApiProvider.overrideWithValue(FakeSessionGateway()),
          sessionExpiryBusProvider.overrideWithValue(expiryBus),
          accountCacheClearerProvider.overrideWithValue(clearAccountCache),
        ],
      );
      await container.read(sessionControllerProvider.future);

      expiryBus.notifyExpired();
      await Future<void>.delayed(Duration.zero);

      expect(store.credential, isNull);
      expect(clearedAccounts, <String>['42']);
      expect(
        container.read(sessionControllerProvider).requireValue,
        isA<ExpiredSession>(),
      );

      container.read(sessionControllerProvider.notifier).continueAsGuest();
      expect(
        container.read(sessionControllerProvider).requireValue,
        isA<GuestSession>(),
      );
    },
  );
}
