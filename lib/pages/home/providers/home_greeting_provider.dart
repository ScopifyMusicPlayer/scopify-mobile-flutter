import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scopify_mobile/modules/session/session_controller.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';

typedef HomeClock = DateTime Function();

final homeClockProvider = Provider<HomeClock>((ref) => DateTime.now);

final homeGreetingProvider = Provider<String>((ref) {
  final session = ref
      .watch(sessionControllerProvider)
      .when(
        data: (value) => value,
        loading: () => const GuestSession(),
        error: (_, _) => const GuestSession(),
      );
  final nickname = session is AuthenticatedSession
      ? session.profile.nickname.trim()
      : '';
  final greeting = homeGreetingFor(ref.watch(homeClockProvider)());
  return nickname.isEmpty ? greeting : '$greeting，$nickname';
});

String homeGreetingFor(DateTime time) {
  final hour = time.hour;
  if (hour >= 5 && hour < 10) return '早上好';
  if (hour >= 10 && hour < 17) return '下午好';
  if (hour >= 17 && hour < 22) return '傍晚好';
  return '晚上好';
}
