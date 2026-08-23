import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';
import 'package:scopify_mobile/shared/network/dio_runtime.dart';

abstract interface class VipSignGateway {
  Future<VipSignHistory> fetchHistory();

  Future<VipSignResult> signToday();
}

class VipSignApi implements VipSignGateway {
  const VipSignApi(this._runtime);

  final DioRuntime _runtime;

  @override
  Future<VipSignHistory> fetchHistory() async {
    final response = await _runtime.get<Map<String, dynamic>>(
      '/vip/sign/history',
      queryParameters: const <String, Object?>{'type': 1},
      requiresSession: true,
    );
    final data = _map(response['data']);
    final rawDays = data['signInfoList'];
    final days = rawDays is List
        ? rawDays.whereType<Map>().map(_dayFromResponse).toList(growable: false)
        : const <VipSignDay>[];
    return VipSignHistory(
      days: days,
      subText: _text(data['subText']),
      buttonText: _text(data['btnText'], fallback: '查看乐签'),
    );
  }

  @override
  Future<VipSignResult> signToday() async {
    final response = await _runtime.post<Map<String, dynamic>>(
      '/vip/sign',
      data: const <String, Object?>{},
      requiresSession: true,
    );
    final data = _map(response['data']);
    final signed = response['signed'] == true || data['signed'] == true;
    return VipSignResult(
      signed: signed,
      message: _text(
        response['message'] ?? response['msg'] ?? data['message'],
        fallback: signed ? '签到成功' : '今日已签到',
      ),
    );
  }
}

VipSignDay _dayFromResponse(Map response) {
  final json = _map(response);
  return VipSignDay(
    dayText: _text(json['dayText']),
    isSigned: json['sign'] == true,
    songCoverUrl: _text(json['songCoverUrl']),
    signTime: _int(json['signTime']),
    isToday: json['today'] == true,
  );
}

Map<String, Object?> _map(Object? value) => value is Map
    ? Map<String, Object?>.fromEntries(
        value.entries.map(
          (entry) => MapEntry(entry.key.toString(), entry.value),
        ),
      )
    : const <String, Object?>{};

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

int _int(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text) ?? 0,
  _ => 0,
};

final vipSignApiProvider = Provider<VipSignGateway>(
  (ref) => VipSignApi(ref.watch(dioRuntimeProvider)),
);
