import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/endpoint/backend_endpoint.dart';
import 'package:scopify_mobile/pages/account/api/vip_sign_api.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.body);

  final Map<String, Object?> body;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
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
    'reads the seven-day history and keeps the session request scoped',
    () async {
      final adapter = _RecordingAdapter(<String, Object?>{
        'code': 200,
        'data': <String, Object?>{
          'subText': '连续签到 2 天',
          'btnText': '查看乐签',
          'signInfoList': <Map<String, Object?>>[
            <String, Object?>{
              'dayText': '23日',
              'sign': true,
              'songCoverUrl': 'https://example.test/cover.jpg',
              'signTime': 1724400000000,
              'today': true,
            },
            <String, Object?>{
              'dayText': '22日',
              'sign': false,
              'songCoverUrl': null,
              'signTime': 1724313600000,
              'today': false,
            },
          ],
        },
      });
      final dio = Dio(
        BaseOptions(baseUrl: BackendEndpoint.defaultValue.baseUrl),
      )..httpClientAdapter = adapter;
      final runtime = DioRuntime(
        endpoint: BackendEndpoint.defaultValue,
        dio: dio,
        sessionAccess: DioSessionAccess(
          readCredential: () async => 'music-cookie',
          onExpired: () {},
        ),
      );

      final history = await VipSignApi(runtime).fetchHistory();

      expect(history.subText, '连续签到 2 天');
      expect(history.buttonText, '查看乐签');
      expect(history.signedToday, isTrue);
      expect(history.signedDayCount, 1);
      expect(history.today?.songCoverUrl, 'https://example.test/cover.jpg');
      expect(adapter.request?.queryParameters['type'], 1);
      expect(adapter.request?.queryParameters['cookie'], 'music-cookie');
    },
  );

  test('serializes history for the account-scoped query cache', () {
    const original = VipSignHistory(
      days: <VipSignDay>[
        VipSignDay(
          dayText: '23日',
          isSigned: true,
          songCoverUrl: '',
          signTime: 1724400000000,
          isToday: true,
        ),
      ],
      subText: '连续签到 1 天',
      buttonText: '查看乐签',
    );

    final restored = VipSignHistory.fromJson(original.toJson());

    expect(restored.signedToday, isTrue);
    expect(restored.signedDayCount, 1);
    expect(restored.today?.dayText, '23日');
    expect(restored.subText, '连续签到 1 天');
  });

  test('submits today sign and preserves the backend message', () async {
    final adapter = _RecordingAdapter(<String, Object?>{
      'code': 200,
      'signed': true,
      'message': '签到成功，明天继续。',
    });
    final dio = Dio(BaseOptions(baseUrl: BackendEndpoint.defaultValue.baseUrl))
      ..httpClientAdapter = adapter;
    final runtime = DioRuntime(
      endpoint: BackendEndpoint.defaultValue,
      dio: dio,
      sessionAccess: DioSessionAccess(
        readCredential: () async => 'music-cookie',
        onExpired: () {},
      ),
    );

    final result = await VipSignApi(runtime).signToday();

    expect(result.signed, isTrue);
    expect(result.message, '签到成功，明天继续。');
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.queryParameters['cookie'], 'music-cookie');
  });
}
