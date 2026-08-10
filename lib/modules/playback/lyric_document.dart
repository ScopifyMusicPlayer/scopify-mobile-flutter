class LyricLine {
  const LyricLine({required this.at, required this.text, this.translation});

  final Duration at;
  final String text;
  final String? translation;

  Map<String, Object?> toJson() => <String, Object?>{
    'atMilliseconds': at.inMilliseconds,
    'text': text,
    'translation': translation,
  };

  factory LyricLine.fromJson(Map<String, Object?> json) {
    return LyricLine(
      at: Duration(
        milliseconds: json['atMilliseconds'] is int
            ? json['atMilliseconds']! as int
            : 0,
      ),
      text: json['text'] is String ? json['text']! as String : '',
      translation: json['translation'] as String?,
    );
  }
}

class LyricDocument {
  const LyricDocument({required this.lines});

  final List<LyricLine> lines;

  static const fixture = LyricDocument(
    lines: <LyricLine>[
      LyricLine(
        at: Duration.zero,
        text: 'No flask can keep it',
        translation: '没有什么瓶子能留住它',
      ),
      LyricLine(
        at: Duration(seconds: 10),
        text: 'Bubble up and cut right through',
        translation: '气泡升起，穿过所有迟疑',
      ),
      LyricLine(
        at: Duration(seconds: 20),
        text: "But you're someone I believe",
        translation: '但你是我愿意相信的人',
      ),
      LyricLine(
        at: Duration(seconds: 30),
        text: 'You heat me like a fire',
        translation: '你像一团火那样温暖我',
      ),
    ],
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'lines': lines.map((line) => line.toJson()).toList(),
  };

  factory LyricDocument.fromJson(Map<String, Object?> json) {
    final rawLines = json['lines'];
    return LyricDocument(
      lines: rawLines is List
          ? rawLines
                .whereType<Map>()
                .map(
                  (line) => LyricLine.fromJson(Map<String, Object?>.from(line)),
                )
                .toList(growable: false)
          : const <LyricLine>[],
    );
  }
}
