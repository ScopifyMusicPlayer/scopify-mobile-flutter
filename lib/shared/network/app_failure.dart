import 'package:dio/dio.dart';

/// A stable, user-safe failure surface for requests made through [DioRuntime].
///
/// Callers should use [message] for a page-level state and may inspect [kind]
/// only when a retry or configuration action differs.
class AppFailure implements Exception {
  const AppFailure._({
    required this.kind,
    required this.message,
    this.statusCode,
  });

  factory AppFailure.fromDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const AppFailure._(
        kind: AppFailureKind.timeout,
        message: '连接后端超时，请稍后重试。',
      ),
      DioExceptionType.connectionError => const AppFailure._(
        kind: AppFailureKind.connection,
        message: '无法连接后端，请检查地址和网络。',
      ),
      DioExceptionType.badResponse => AppFailure._(
        kind: AppFailureKind.response,
        message: '后端返回了无法使用的响应。',
        statusCode: error.response?.statusCode,
      ),
      _ => const AppFailure._(
        kind: AppFailureKind.unknown,
        message: '请求暂时没有完成，请稍后重试。',
      ),
    };
  }

  factory AppFailure.business({required String message, int? statusCode}) {
    return AppFailure._(
      kind: AppFailureKind.business,
      message: message,
      statusCode: statusCode,
    );
  }

  final AppFailureKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => 'AppFailure($kind, $statusCode): $message';
}

enum AppFailureKind { timeout, connection, response, business, unknown }
