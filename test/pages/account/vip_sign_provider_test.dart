import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/pages/account/api/vip_sign_api.dart';
import 'package:scopify_mobile/pages/account/providers/vip_sign_provider.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../support/session_fakes.dart';
import '../../support/vip_sign_fakes.dart';

class _FixedEndpointController extends BackendEndpointController {
  @override
  Future<BackendEndpoint> build() async => BackendEndpoint.defaultValue;
}

void main() {
  sqfliteFfiInit();

  test(
    'loads once and then serves fresh history from the account cache',
    () async {
      final cache = QueryCacheStore(
        factory: databaseFactoryFfi,
        databasePath: () async => inMemoryDatabasePath,
        clock: DateTime.now,
      );
      final gateway = FakeVipSignGateway();
      final container = ProviderContainer.test(
        overrides: [
          credentialStoreProvider.overrideWithValue(
            MemoryCredentialStore(
              credential: const StoredSessionCredential(
                cookie: 'music-cookie',
                endpointId: 'http://10.0.2.2:3838',
              ),
            ),
          ),
          sessionApiProvider.overrideWithValue(FakeSessionGateway()),
          backendEndpointControllerProvider.overrideWith(
            _FixedEndpointController.new,
          ),
          vipSignApiProvider.overrideWithValue(gateway),
          queryCacheStoreProvider.overrideWithValue(cache),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(cache.close);

      final first = await container.read(vipSignHistoryProvider.future);
      final fetchesAfterFirstLoad = gateway.fetchCount;
      container.invalidate(vipSignHistoryProvider);
      final second = await container.read(vipSignHistoryProvider.future);

      expect(first.signedToday, isTrue);
      expect(second.subText, '连续签到 1 天');
      expect(fetchesAfterFirstLoad, greaterThanOrEqualTo(1));
      expect(gateway.fetchCount, fetchesAfterFirstLoad);
    },
  );

  test('does not read the endpoint for a guest session', () async {
    final container = ProviderContainer.test(
      overrides: [
        credentialStoreProvider.overrideWithValue(MemoryCredentialStore()),
        sessionApiProvider.overrideWithValue(FakeSessionGateway()),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(vipSignHistoryProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test(
    'sign action delegates once and refreshes the history provider',
    () async {
      final gateway = FakeVipSignGateway(
        result: const VipSignResult(signed: true, message: '签到成功'),
      );
      final container = ProviderContainer.test(
        overrides: [vipSignApiProvider.overrideWithValue(gateway)],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(vipSignActionProvider.notifier)
          .signToday();

      expect(result.signed, isTrue);
      expect(gateway.signCount, 1);
      expect(container.read(vipSignActionProvider).isSubmitting, isFalse);
    },
  );
}
