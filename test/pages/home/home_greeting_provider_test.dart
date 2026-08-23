import 'package:flutter_test/flutter_test.dart';
import 'package:scopify_mobile/pages/home/providers/home_greeting_provider.dart';

void main() {
  test('maps the Web time-theme boundaries to mobile greeting text', () {
    final cases = <(int, String)>[
      (0, '晚上好'),
      (4, '晚上好'),
      (5, '早上好'),
      (9, '早上好'),
      (10, '下午好'),
      (16, '下午好'),
      (17, '傍晚好'),
      (21, '傍晚好'),
      (22, '晚上好'),
      (23, '晚上好'),
    ];

    for (final (hour, greeting) in cases) {
      expect(
        homeGreetingFor(DateTime(2026, 8, 23, hour)),
        greeting,
        reason: 'hour $hour',
      );
    }
  });
}
