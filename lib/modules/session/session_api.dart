import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

abstract interface class SessionGateway {
  String get endpointId;

  Future<void> revokeCredential(String cookie);

  Future<SessionProfile> validateCredential(String cookie);
}

class SessionApi implements SessionGateway {
  SessionApi(this._runtime);

  final DioRuntime _runtime;

  @override
  String get endpointId => _runtime.endpoint.id;

  @override
  Future<void> revokeCredential(String cookie) async {
    await _runtime.get<Map<String, dynamic>>(
      '/logout',
      queryParameters: <String, Object?>{'cookie': cookie},
      expectedBusinessCodes: const <int>{200, 301},
    );
  }

  @override
  Future<SessionProfile> validateCredential(String cookie) async {
    final loginStatus = await _runtime.post<Map<String, dynamic>>(
      '/login/status',
      data: <String, Object?>{'cookie': cookie},
    );
    final statusData = _asMap(loginStatus['data']);
    final statusAccount = _asMap(statusData['account']);
    final statusProfile = _asMap(statusData['profile']);
    final statusUserId =
        _asInt(statusAccount['id']) ?? _asInt(statusProfile['userId']);
    if (statusUserId == null) {
      throw AppFailure.business(message: '登录状态校验失败，请重新扫码。');
    }

    final account = await _runtime.get<Map<String, dynamic>>(
      '/user/account',
      queryParameters: <String, Object?>{'cookie': cookie},
    );
    final profile = _asMap(account['profile']);
    final userId = _asInt(profile['userId']) ?? statusUserId;
    return SessionProfile(
      userId: userId,
      nickname: _asString(profile['nickname']) ?? '网易云用户',
      avatarUrl: _asString(profile['avatarUrl']) ?? '',
      signature: _asString(profile['signature']) ?? '',
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int? _asInt(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text),
  _ => null,
};

String? _asString(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

final sessionApiProvider = Provider<SessionGateway>(
  (ref) => SessionApi(ref.watch(dioRuntimeProvider)),
);
