import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_cache_cleanup.dart';
import 'package:scopify_mobile/modules/session/session_expiry_bus.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';
import 'package:scopify_mobile/shared/network/app_failure.dart';

part 'session_controller.g.dart';

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  bool _expirationInFlight = false;

  @override
  Future<SessionState> build() async {
    final store = ref.watch(credentialStoreProvider);
    final api = ref.watch(sessionApiProvider);
    final expirySubscription = ref
        .watch(sessionExpiryBusProvider)
        .events
        .listen((_) => unawaited(_expireSession()));
    ref.onDispose(expirySubscription.cancel);

    try {
      final stored = await store.read();
      if (stored == null) return const GuestSession();
      if (stored.endpointId != api.endpointId) {
        await store.clear();
        return const GuestSession();
      }
      final profile = await api.validateCredential(stored.cookie);
      return AuthenticatedSession(profile: profile);
    } on AppFailure catch (failure) {
      if (failure.kind != AppFailureKind.business &&
          failure.kind != AppFailureKind.unauthenticated) {
        rethrow;
      }
      await store.clear();
      return const GuestSession();
    }
  }

  Future<SessionProfile> establish(
    String cookie, {
    bool Function()? shouldCommit,
  }) async {
    if (cookie.isEmpty) {
      throw const FormatException('二维码没有返回登录凭据。');
    }

    final canCommit = shouldCommit ?? () => true;
    final api = ref.read(sessionApiProvider);
    final profile = await api.validateCredential(cookie);
    if (!canCommit()) throw const SessionEstablishmentCancelled();
    await ref
        .read(credentialStoreProvider)
        .save(
          StoredSessionCredential(cookie: cookie, endpointId: api.endpointId),
        );
    if (!canCommit()) {
      await ref.read(credentialStoreProvider).clear();
      throw const SessionEstablishmentCancelled();
    }
    state = AsyncData<SessionState>(AuthenticatedSession(profile: profile));
    return profile;
  }

  Future<void> signOut() async {
    final current = state.value;
    if (current is! AuthenticatedSession) {
      state = const AsyncData<SessionState>(GuestSession());
      return;
    }

    final api = ref.read(sessionApiProvider);
    final store = ref.read(credentialStoreProvider);
    final credential = await store.read();
    if (credential?.endpointId == api.endpointId) {
      try {
        await api.revokeCredential(credential!.cookie);
      } on Object {
        // Remote logout is best-effort; local credentials must still be removed.
      }
    }
    await _clearLocalAccount(current.profile, endpointId: api.endpointId);
    state = const AsyncData<SessionState>(GuestSession());
  }

  void continueAsGuest() {
    if (state.value is ExpiredSession) {
      state = const AsyncData<SessionState>(GuestSession());
    }
  }

  Future<void> _expireSession() async {
    if (_expirationInFlight) return;
    final current = state.value;
    if (current is! AuthenticatedSession) return;

    _expirationInFlight = true;
    try {
      await _clearLocalAccount(
        current.profile,
        endpointId: ref.read(sessionApiProvider).endpointId,
      );
      state = const AsyncData<SessionState>(ExpiredSession());
    } finally {
      _expirationInFlight = false;
    }
  }

  Future<void> _clearLocalAccount(
    SessionProfile profile, {
    required String endpointId,
  }) async {
    await ref.read(credentialStoreProvider).clear();
    await ref.read(accountCacheClearerProvider)(
      endpointId: endpointId,
      accountId: profile.userId.toString(),
    );
  }
}

class SessionEstablishmentCancelled implements Exception {
  const SessionEstablishmentCancelled();
}
