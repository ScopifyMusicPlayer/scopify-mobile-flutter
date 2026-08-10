import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/modules/playback/lyric_parser.dart';

void main() {
  group('LyricParser', () {
    test('aligns JSON-line lyrics and translation by timestamp', () {
      final document = LyricParser.parse(
        primary: '''
{"t":0,"c":[{"tx":"第一句"}]}
{"t":1500,"c":[{"tx":"第二"},{"tx":"句"}]}
''',
        translated: '''
{"t":1500,"c":[{"tx":"Second line"}]}
''',
      );

      expect(document.lines, hasLength(2));
      expect(document.lines[0].text, '第一句');
      expect(document.lines[0].translation, isNull);
      expect(document.lines[1].at, const Duration(milliseconds: 1500));
      expect(document.lines[1].text, '第二句');
      expect(document.lines[1].translation, 'Second line');
    });

    test('falls back to classic LRC timestamps', () {
      final document = LyricParser.parse(
        primary: '[00:01.20]hello\n[01:02.003]world',
        translated: '[00:01.200]你好\n[01:02.003]世界',
      );

      expect(document.lines.map((line) => line.at), <Duration>[
        const Duration(milliseconds: 1200),
        const Duration(minutes: 1, seconds: 2, milliseconds: 3),
      ]);
      expect(document.lines.map((line) => line.translation), <String?>[
        '你好',
        '世界',
      ]);
    });
  });
}
