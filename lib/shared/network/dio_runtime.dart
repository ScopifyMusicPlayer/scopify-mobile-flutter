import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/modules/endpoint/endpoint_controller.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

/// The one HTTP runtime used by business thin APIs.
///
/// Its interface deliberately exposes request operations instead of a mutable
/// Dio client. Endpoint selection, timeouts, common parameters and conversion
/// to [AppFailure] therefore stay local to this Module.
class DioRuntime {
  DioRuntime({required BackendEndpoint endpoint, Dio? dio})
    : _dio = dio ?? _createClient(endpoint),
      endpoint = endpoint;

  final BackendEndpoint endpoint;
  final Dio _dio;

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
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
      _throwOnBusinessFailure(response.data, response.statusCode);
      final data = response.data;
      if (data == null) {
        throw AppFailure.business(message: '后端没有返回数据。');
      }
      return data;
    } on DioException catch (error) {
      throw AppFailure.fromDio(error);
    }
  }

  void close() => _dio.close(force: true);

  void _throwOnBusinessFailure(Object? data, int? statusCode) {
    if (data is! Map<Object?, Object?>) return;
    final code = data['code'];
    if (code is! num || code.toInt() == 200) return;
    final message = data['msg'] ?? data['message'];
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
  final runtime = DioRuntime(endpoint: endpoint);
  ref.onDispose(runtime.close);
  return runtime;
});
