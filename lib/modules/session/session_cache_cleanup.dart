import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

typedef AccountCacheClearer =
    Future<void> Function({
      required String endpointId,
      required String accountId,
    });

/// Keeps the account-cache deletion policy at the Session boundary while the
/// storage implementation remains owned by the shared query cache.
final accountCacheClearerProvider = Provider<AccountCacheClearer>((ref) {
  final store = ref.watch(queryCacheStoreProvider);

  Future<void> clear({required String endpointId, required String accountId}) {
    return store.clearScope(
      endpointId: endpointId,
      scope: 'account',
      accountId: accountId,
    );
  }

  return clear;
});
