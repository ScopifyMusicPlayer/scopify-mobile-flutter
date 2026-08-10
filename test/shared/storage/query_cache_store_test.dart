import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  group('QueryCacheStore', () {
    late DateTime now;
    late QueryCacheStore store;

    setUp(() {
      now = DateTime.utc(2026, 8, 10, 10);
      store = QueryCacheStore(
        factory: databaseFactoryFfi,
        databasePath: () async => inMemoryDatabasePath,
        clock: () => now,
      );
    });

    tearDown(() => store.close());

    test('uses a stable key even when query parameter order differs', () {
      final first = _key(
        parameters: <String, Object?>{'limit': 12, 'tag': 'new'},
      );
      final second = _key(
        parameters: <String, Object?>{'tag': 'new', 'limit': 12},
      );

      expect(first.value, second.value);
    });

    test(
      'returns fresh then stale data and removes hard-expired data',
      () async {
        final key = _key();
        await store.write(
          key: key,
          payload: const <String, Object?>{'title': '今日私藏'},
          policy: const QueryCachePolicy(
            freshFor: Duration(minutes: 5),
            maxAge: Duration(hours: 1),
          ),
        );

        expect((await store.read(key))!.isFreshAt(now), isTrue);

        now = now.add(const Duration(minutes: 6));
        expect((await store.read(key))!.isFreshAt(now), isFalse);

        now = now.add(const Duration(hours: 1));
        expect(await store.read(key), isNull);
      },
    );

    test('clears only the selected endpoint account scope', () async {
      final publicKey = _key();
      final accountKey = _key(accountId: '42', scope: 'account');
      final otherEndpointKey = _key(endpointId: 'https://other.example.test');
      const policy = QueryCachePolicy(
        freshFor: Duration(minutes: 5),
        maxAge: Duration(hours: 1),
      );

      await store.write(
        key: publicKey,
        payload: const <String, Object?>{'value': 'public'},
        policy: policy,
      );
      await store.write(
        key: accountKey,
        payload: const <String, Object?>{'value': 'account'},
        policy: policy,
      );
      await store.write(
        key: otherEndpointKey,
        payload: const <String, Object?>{'value': 'other'},
        policy: policy,
      );

      await store.clearScope(
        endpointId: 'http://10.0.2.2:3838',
        scope: 'account',
        accountId: '42',
      );

      expect(await store.read(publicKey), isNotNull);
      expect(await store.read(accountKey), isNull);
      expect(await store.read(otherEndpointKey), isNotNull);
    });
  });
}

QueryCacheKey _key({
  String endpointId = 'http://10.0.2.2:3838',
  String accountId = 'public',
  String scope = 'public',
  Map<String, Object?> parameters = const <String, Object?>{'limit': 12},
}) {
  return QueryCacheKey(
    endpointId: endpointId,
    accountId: accountId,
    scope: scope,
    query: 'home.personalizedPlaylists',
    parameters: parameters,
    schemaVersion: 1,
  );
}
