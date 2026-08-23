import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.body);

  final Map<String, Object?> body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'session request injects its credential and reports business code 301',
    () async {
      final adapter = _RecordingAdapter(<String, Object?>{
        'code': 301,
        'message': '需要登录',
      });
      final dio = Dio(
        BaseOptions(baseUrl: BackendEndpoint.defaultValue.baseUrl),
      )..httpClientAdapter = adapter;
      var expiryNotifications = 0;
      final runtime = DioRuntime(
        endpoint: BackendEndpoint.defaultValue,
        dio: dio,
        sessionAccess: DioSessionAccess(
          readCredential: () async => 'music-cookie',
          onExpired: () => expiryNotifications++,
        ),
      );

      await expectLater(
        runtime.get<Map<String, dynamic>>(
          '/account/resource',
          requiresSession: true,
        ),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            AppFailureKind.unauthenticated,
          ),
        ),
      );

      expect(adapter.lastRequest?.queryParameters['cookie'], 'music-cookie');
      expect(expiryNotifications, 1);
    },
  );

  test(
    'public request neither reads nor attaches a session credential',
    () async {
      final adapter = _RecordingAdapter(<String, Object?>{'code': 200});
      final dio = Dio(
        BaseOptions(baseUrl: BackendEndpoint.defaultValue.baseUrl),
      )..httpClientAdapter = adapter;
      var credentialReads = 0;
      final runtime = DioRuntime(
        endpoint: BackendEndpoint.defaultValue,
        dio: dio,
        sessionAccess: DioSessionAccess(
          readCredential: () async {
            credentialReads++;
            return 'music-cookie';
          },
          onExpired: () {},
        ),
      );

      await runtime.get<Map<String, dynamic>>('/public/resource');

      expect(credentialReads, 0);
      expect(adapter.lastRequest?.queryParameters, isNot(contains('cookie')));
    },
  );
}
