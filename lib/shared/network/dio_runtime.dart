import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_expiry_bus.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

class DioSessionAccess {
  const DioSessionAccess({
    required this.readCredential,
    required this.onExpired,
  });

  final Future<String?> Function() readCredential;
  final void Function() onExpired;
}

/// The one HTTP runtime used by business thin APIs.
///
/// Its interface deliberately exposes request operations instead of a mutable
/// Dio client. Endpoint selection, timeouts, common parameters and conversion
/// to [AppFailure] therefore stay local to this Module.
class DioRuntime {
  DioRuntime({required BackendEndpoint endpoint, Dio? dio, this.sessionAccess})
    : _dio = dio ?? _createClient(endpoint),
      endpoint = endpoint;

  final BackendEndpoint endpoint;
  final Dio _dio;
  final DioSessionAccess? sessionAccess;

  static Dio _createClient(BackendEndpoint endpoint) {
    final dio = Dio(
      BaseOptions(
        baseUrl: endpoint.baseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
        headers: const <String, Object>{'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters = <String, Object?>{
            ...options.queryParameters,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'platform': defaultTargetPlatform.name,
          };
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  Future<T> get<T>(
    String path, {
    Map<String, Object?> queryParameters = const <String, Object?>{},
    Set<int> expectedBusinessCodes = const <int>{200},
    bool requiresSession = false,
  }) async {
    try {
      final requestParameters = await _withSession(
        queryParameters,
        requiresSession: requiresSession,
      );
      final response = await _dio.get<T>(
        path,
        queryParameters: requestParameters,
      );
      _throwOnBusinessFailure(
        response.data,
        response.statusCode,
        expectedBusinessCodes,
      );
      final data = response.data;
      if (data == null) {
        throw AppFailure.business(message: '后端没有返回数据。');
      }
      return data;
    } on AppFailure catch (failure) {
      _notifyIfSessionExpired(failure, requiresSession: requiresSession);
      rethrow;
    } on DioException catch (error) {
      final failure = AppFailure.fromDio(error);
      _notifyIfSessionExpired(failure, requiresSession: requiresSession);
      throw failure;
    }
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, Object?> queryParameters = const <String, Object?>{},
    Set<int> expectedBusinessCodes = const <int>{200},
    bool requiresSession = false,
  }) async {
    try {
      final requestParameters = await _withSession(
        queryParameters,
        requiresSession: requiresSession,
      );
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: requestParameters,
      );
      _throwOnBusinessFailure(
        response.data,
        response.statusCode,
        expectedBusinessCodes,
      );
      final responseData = response.data;
      if (responseData == null) {
        throw AppFailure.business(message: '后端没有返回数据。');
      }
      return responseData;
    } on AppFailure catch (failure) {
      _notifyIfSessionExpired(failure, requiresSession: requiresSession);
      rethrow;
    } on DioException catch (error) {
      final failure = AppFailure.fromDio(error);
      _notifyIfSessionExpired(failure, requiresSession: requiresSession);
      throw failure;
    }
  }

  void close() => _dio.close(force: true);

  Future<Map<String, Object?>> _withSession(
    Map<String, Object?> queryParameters, {
    required bool requiresSession,
  }) async {
    if (!requiresSession || queryParameters.containsKey('cookie')) {
      return queryParameters;
    }
    final cookie = await sessionAccess?.readCredential();
    if (cookie == null || cookie.isEmpty) {
      throw AppFailure.unauthenticated();
    }
    return <String, Object?>{...queryParameters, 'cookie': cookie};
  }

  void _notifyIfSessionExpired(
    AppFailure failure, {
    required bool requiresSession,
  }) {
    if (requiresSession && failure.kind == AppFailureKind.unauthenticated) {
      sessionAccess?.onExpired();
    }
  }

  void _throwOnBusinessFailure(
    Object? data,
    int? statusCode,
    Set<int> expectedBusinessCodes,
  ) {
    if (data is! Map<Object?, Object?>) return;
    final code = data['code'];
    if (code is! num || expectedBusinessCodes.contains(code.toInt())) return;
    final message = data['msg'] ?? data['message'];
    if (code.toInt() == 301) {
      throw AppFailure.unauthenticated(
        message: message is String && message.isNotEmpty ? message : null,
        statusCode: statusCode,
      );
    }
    throw AppFailure.business(
      message: message is String && message.isNotEmpty ? message : '后端请求失败。',
      statusCode: statusCode,
    );
  }
}

final dioRuntimeProvider = Provider<DioRuntime>((ref) {
  final endpointState = ref.watch(backendEndpointControllerProvider);
  final endpoint = endpointState.when(
    data: (value) => value,
    loading: () => BackendEndpoint.defaultValue,
    error: (_, _) => BackendEndpoint.defaultValue,
  );
  final credentialStore = ref.watch(credentialStoreProvider);
  final expiryBus = ref.watch(sessionExpiryBusProvider);
  final runtime = DioRuntime(
    endpoint: endpoint,
    sessionAccess: DioSessionAccess(
      readCredential: () async {
        final credential = await credentialStore.read();
        if (credential?.endpointId != endpoint.id) return null;
        return credential?.cookie;
      },
      onExpired: expiryBus.notifyExpired,
    ),
  );
  ref.onDispose(runtime.close);
  return runtime;
});
