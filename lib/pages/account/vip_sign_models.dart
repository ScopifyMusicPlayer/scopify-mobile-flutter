class VipSignHistory {
  const VipSignHistory({
    required this.days,
    required this.subText,
    required this.buttonText,
  });

  final List<VipSignDay> days;
  final String subText;
  final String buttonText;

  VipSignDay? get today {
    for (final day in days) {
      if (day.isToday) return day;
    }
    return null;
  }

  bool get signedToday => today?.isSigned ?? false;

  int get signedDayCount => days.where((day) => day.isSigned).length;

  Map<String, Object?> toJson() => <String, Object?>{
    'days': days.map((day) => day.toJson()).toList(),
    'subText': subText,
    'buttonText': buttonText,
  };

  factory VipSignHistory.fromJson(Map<String, Object?> json) {
    final rawDays = json['days'];
    return VipSignHistory(
      days: rawDays is List
          ? rawDays
                .whereType<Map>()
                .map(
                  (day) => VipSignDay.fromJson(
                    Map<String, Object?>.fromEntries(
                      day.entries.map(
                        (entry) => MapEntry(entry.key.toString(), entry.value),
                      ),
                    ),
                  ),
                )
                .toList(growable: false)
          : const <VipSignDay>[],
      subText: _text(json['subText']),
      buttonText: _text(json['buttonText'], fallback: '查看乐签'),
    );
  }
}

class VipSignResult {
  const VipSignResult({required this.signed, required this.message});

  final bool signed;
  final String message;
}

class VipSignDay {
  const VipSignDay({
    required this.dayText,
    required this.isSigned,
    required this.songCoverUrl,
    required this.signTime,
    required this.isToday,
  });

  final String dayText;
  final bool isSigned;
  final String songCoverUrl;
  final int signTime;
  final bool isToday;

  Map<String, Object?> toJson() => <String, Object?>{
    'dayText': dayText,
    'isSigned': isSigned,
    'songCoverUrl': songCoverUrl,
    'signTime': signTime,
    'isToday': isToday,
  };

  factory VipSignDay.fromJson(Map<String, Object?> json) => VipSignDay(
    dayText: _text(json['dayText']),
    isSigned: json['isSigned'] == true,
    songCoverUrl: _text(json['songCoverUrl']),
    signTime: _int(json['signTime']),
    isToday: json['isToday'] == true,
  );
}

String _text(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

int _int(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  String text => int.tryParse(text) ?? 0,
  _ => 0,
};
