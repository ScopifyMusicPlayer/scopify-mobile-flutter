import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/account/api/account_api.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

const _accountOverviewPolicy = QueryCachePolicy(
  freshFor: Duration(minutes: 5),
  maxAge: Duration(hours: 6),
);

final accountOverviewProvider = FutureProvider<AccountOverview>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);
  if (session is! AuthenticatedSession) {
    throw StateError('需要登录后才能读取账号资料。');
  }
  final endpoint = await ref.watch(backendEndpointControllerProvider.future);
  final cache = ref.watch(queryCacheStoreProvider);
  final key = QueryCacheKey(
    endpointId: endpoint.id,
    accountId: session.profile.userId.toString(),
    scope: 'account',
    query: 'account.overview',
    parameters: const <String, Object?>{},
    schemaVersion: 1,
  );
  final cached = await cache.read(key);
  if (cached != null && cached.isFreshAt(DateTime.now())) {
    return AccountOverview.fromJson(cached.payload);
  }

  final overview = await ref
      .read(accountApiProvider)
      .fetchOverview(session.profile);
  await cache.write(
    key: key,
    payload: overview.toJson(),
    policy: _accountOverviewPolicy,
  );
  return overview;
});
