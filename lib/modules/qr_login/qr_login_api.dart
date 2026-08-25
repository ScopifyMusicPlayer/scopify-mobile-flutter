import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

class QrLoginKey {
  const QrLoginKey(this.value);

  final String value;
}

class QrLoginImage {
  const QrLoginImage(this.dataUri);

  final String dataUri;
}

class QrLoginCheck {
  const QrLoginCheck({required this.code, this.cookie});

  final int code;
  final String? cookie;
}

abstract interface class QrLoginGateway {
  Future<QrLoginCheck> check(String key);

  Future<QrLoginImage> create(String key);

  Future<QrLoginKey> requestKey();
}

class QrLoginApi implements QrLoginGateway {
  QrLoginApi(this._runtime);

  final DioRuntime _runtime;

  @override
  Future<QrLoginKey> requestKey() async {
    final response = await _runtime.get<Map<String, dynamic>>('/login/qr/key');
    final data = _asMap(response['data']);
    final key = data['unikey'];
    if (key is! String || key.isEmpty) {
      throw AppFailure.business(message: '后端没有返回二维码登录 Key。');
    }
    return QrLoginKey(key);
  }

  @override
  Future<QrLoginImage> create(String key) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/login/qr/create',
      queryParameters: <String, Object?>{'key': key, 'qrimg': true},
    );
    final data = _asMap(response['data']);
    final image = data['qrimg'];
    if (image is! String || image.isEmpty) {
      throw AppFailure.business(message: '后端没有返回二维码图片。');
    }
    return QrLoginImage(image);
  }

  @override
  Future<QrLoginCheck> check(String key) async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/login/qr/check',
      queryParameters: <String, Object?>{'key': key},
      expectedBusinessCodes: const <int>{800, 801, 802, 803},
    );
    final code = response['code'];
    if (code is! num) {
      throw AppFailure.business(message: '后端返回了无法识别的扫码状态。');
    }
    return QrLoginCheck(
      code: code.toInt(),
      cookie: response['cookie'] is String
          ? response['cookie']! as String
          : null,
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

final qrLoginApiProvider = Provider<QrLoginGateway>(
  (ref) => QrLoginApi(ref.watch(dioRuntimeProvider)),
);
