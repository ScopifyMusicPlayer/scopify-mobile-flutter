import 'package:scopify_mobile/pages/account/api/vip_sign_api.dart';
import 'package:scopify_mobile/pages/account/vip_sign_models.dart';

class FakeVipSignGateway implements VipSignGateway {
  FakeVipSignGateway({VipSignHistory? history, VipSignResult? result})
    : history = history ?? defaultVipSignHistory,
      result = result ?? const VipSignResult(signed: true, message: '签到成功');

  final VipSignHistory history;
  final VipSignResult result;
  int fetchCount = 0;
  int signCount = 0;

  @override
  Future<VipSignHistory> fetchHistory() async {
    fetchCount++;
    return history;
  }

  @override
  Future<VipSignResult> signToday() async {
    signCount++;
    return result;
  }
}

const defaultVipSignHistory = VipSignHistory(
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
