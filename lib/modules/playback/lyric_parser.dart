import 'dart:convert';

import 'package:scopify_mobile/modules/playback/lyric_document.dart';

class LyricParser {
  const LyricParser._();

  static LyricDocument parse({String? primary, String? translated}) {
    final primaryLines = _parseTimedJson(primary);
    final translatedByTimestamp = <int, String>{
      for (final line in _parseTimedJson(translated))
        line.at.inMilliseconds: line.text,
    };
    if (primaryLines.isNotEmpty) {
      return LyricDocument(
        lines: primaryLines
            .map(
              (line) => LyricLine(
                at: line.at,
                text: line.text,
                translation: translatedByTimestamp[line.at.inMilliseconds],
              ),
            )
            .toList(growable: false),
      );
    }
    return LyricDocument(lines: _parseLrc(primary, translated));
  }

  static List<_UntitledLyricLine> _parseTimedJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <_UntitledLyricLine>[];
    final lines = <_UntitledLyricLine>[];
    for (final sourceLine in const LineSplitter().convert(raw)) {
      try {
        final value = jsonDecode(sourceLine);
        if (value is! Map) continue;
        final timestamp = value['t'];
        final chunks = value['c'];
        if (timestamp is! num || chunks is! List) continue;
        final text = chunks
            .whereType<Map>()
            .map((chunk) => chunk['tx'])
            .whereType<String>()
            .join()
            .trim();
        if (text.isEmpty) continue;
        lines.add(
          _UntitledLyricLine(
            at: Duration(milliseconds: timestamp.toInt()),
            text: text,
          ),
        );
      } on FormatException {
        continue;
      }
    }
    return lines;
  }

  static List<LyricLine> _parseLrc(String? primary, String? translated) {
    final translatedByTimestamp = <int, String>{
      for (final line in _parseLrcLines(translated))
        line.at.inMilliseconds: line.text,
    };
    return _parseLrcLines(primary)
        .map(
          (line) => LyricLine(
            at: line.at,
            text: line.text,
            translation: translatedByTimestamp[line.at.inMilliseconds],
          ),
        )
        .toList(growable: false);
  }

  static List<_UntitledLyricLine> _parseLrcLines(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <_UntitledLyricLine>[];
    final pattern = RegExp(r'^\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\](.*)$');
    return const LineSplitter()
        .convert(raw)
        .map((sourceLine) {
          final match = pattern.firstMatch(sourceLine.trim());
          if (match == null) return null;
          final text = match.group(4)?.trim() ?? '';
          if (text.isEmpty) return null;
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final fraction = (match.group(3) ?? '').padRight(3, '0');
          return _UntitledLyricLine(
            at: Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: fraction.isEmpty ? 0 : int.parse(fraction),
            ),
            text: text,
          );
        })
        .whereType<_UntitledLyricLine>()
        .toList(growable: false);
  }
}

class _UntitledLyricLine {
  const _UntitledLyricLine({required this.at, required this.text});

  final Duration at;
  final String text;
}
