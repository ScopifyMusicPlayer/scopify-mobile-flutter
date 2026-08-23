import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Carries an explicit unauthenticated response from the network boundary to
/// the long-lived session owner without coupling business APIs to UI state.
class SessionExpiryBus {
  final StreamController<void> _controller = StreamController<void>.broadcast(
    sync: true,
  );

  Stream<void> get events => _controller.stream;

  void notifyExpired() => _controller.add(null);

  Future<void> close() => _controller.close();
}

final sessionExpiryBusProvider = Provider<SessionExpiryBus>((ref) {
  final bus = SessionExpiryBus();
  ref.onDispose(bus.close);
  return bus;
});
