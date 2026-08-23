import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/pages/account/api/vip_sign_api.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';
import 'package:scopify_mobile/shared/storage/query_cache_store.dart';

const _vipSignPolicy = QueryCachePolicy(
  freshFor: Duration(minutes: 2),
  maxAge: Duration(hours: 6),
);

final vipSignHistoryProvider = FutureProvider<VipSignHistory>((ref) async {
  final session = await ref.watch(sessionControllerProvider.future);
  if (session is! AuthenticatedSession) {
    throw StateError('需要登录后才能读取乐签。');
  }

  final endpoint = await ref.watch(backendEndpointControllerProvider.future);
  final cache = ref.watch(queryCacheStoreProvider);
  final key = QueryCacheKey(
    endpointId: endpoint.id,
    accountId: session.profile.userId.toString(),
    scope: 'account',
    query: 'account.vipSignHistory',
    parameters: const <String, Object?>{'type': 1},
    schemaVersion: 1,
  );
  final cached = await cache.read(key);
  if (cached != null && cached.isFreshAt(DateTime.now())) {
    return VipSignHistory.fromJson(cached.payload);
  }

  final history = await ref.read(vipSignApiProvider).fetchHistory();
  await cache.write(
    key: key,
    payload: history.toJson(),
    policy: _vipSignPolicy,
  );
  return history;
});

class VipSignActionState {
  const VipSignActionState({
    this.isSubmitting = false,
    this.errorMessage,
    this.result,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final VipSignResult? result;

  VipSignActionState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    VipSignResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return VipSignActionState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      result: clearResult ? null : result ?? this.result,
    );
  }
}

class VipSignActionController extends Notifier<VipSignActionState> {
  @override
  VipSignActionState build() => const VipSignActionState();

  Future<VipSignResult> signToday() async {
    if (state.isSubmitting) {
      throw StateError('签到请求正在提交。');
    }
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final result = await ref.read(vipSignApiProvider).signToday();
      ref.invalidate(vipSignHistoryProvider);
      state = state.copyWith(isSubmitting: false, result: result);
      return result;
    } on Object catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.toString(),
      );
      rethrow;
    }
  }
}

final vipSignActionProvider =
    NotifierProvider<VipSignActionController, VipSignActionState>(
      VipSignActionController.new,
    );
