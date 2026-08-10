import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

class EndpointProbeResult {
  const EndpointProbeResult._({
    required this.endpoint,
    required this.elapsed,
    required this.isReachable,
    this.message,
  });

  factory EndpointProbeResult.reachable({
    required BackendEndpoint endpoint,
    required Duration elapsed,
  }) => EndpointProbeResult._(
    endpoint: endpoint,
    elapsed: elapsed,
    isReachable: true,
  );

  factory EndpointProbeResult.unreachable({
    required BackendEndpoint endpoint,
    required Duration elapsed,
    required String message,
  }) => EndpointProbeResult._(
    endpoint: endpoint,
    elapsed: elapsed,
    isReachable: false,
    message: message,
  );

  final BackendEndpoint endpoint;
  final Duration elapsed;
  final bool isReachable;
  final String? message;
}

/// Owns the persisted backend address and probes the public API surface.
class EndpointStore {
  EndpointStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'scopify.backend.endpoint.v1';
  final SharedPreferencesAsync _preferences;

  Future<BackendEndpoint> read() async {
    final saved = await _preferences.getString(_storageKey);
    if (saved == null) return BackendEndpoint.defaultValue;
    try {
      return BackendEndpoint.parse(saved);
    } on FormatException {
      await _preferences.remove(_storageKey);
      return BackendEndpoint.defaultValue;
    }
  }

  Future<void> save(BackendEndpoint endpoint) =>
      _preferences.setString(_storageKey, endpoint.baseUrl);

  Future<void> restoreDefault() => _preferences.remove(_storageKey);

  Future<EndpointProbeResult> probe(BackendEndpoint endpoint) async {
    final watch = Stopwatch()..start();
    final dio = Dio(
      BaseOptions(
        baseUrl: endpoint.baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 7),
        validateStatus: (status) => status != null && status < 500,
      ),
    );
    try {
      final response = await dio.get<Object>(
        '/personalized',
        queryParameters: const <String, Object?>{'limit': 1},
      );
      final body = response.data;
      final code = body is Map<Object?, Object?> ? body['code'] : null;
      if (response.statusCode != 200 || code is! num || code.toInt() != 200) {
        return EndpointProbeResult.unreachable(
          endpoint: endpoint,
          elapsed: watch.elapsed,
          message: '后端没有通过公开数据探测。',
        );
      }
      return EndpointProbeResult.reachable(
        endpoint: endpoint,
        elapsed: watch.elapsed,
      );
    } on DioException catch (error) {
      return EndpointProbeResult.unreachable(
        endpoint: endpoint,
        elapsed: watch.elapsed,
        message: AppFailure.fromDio(error).message,
      );
    } finally {
      watch.stop();
      dio.close(force: true);
    }
  }
}
