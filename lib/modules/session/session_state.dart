sealed class SessionState {
  const SessionState();

  bool get isAuthenticated => this is AuthenticatedSession;
}

class GuestSession extends SessionState {
  const GuestSession();
}

/// Local credentials have already been removed, but the user must choose how
/// to continue before the application resumes normal interaction.
class ExpiredSession extends SessionState {
  const ExpiredSession();
}

class AuthenticatedSession extends SessionState {
  const AuthenticatedSession({required this.profile});

  final SessionProfile profile;
}

class SessionProfile {
  const SessionProfile({
    required this.userId,
    required this.nickname,
    required this.avatarUrl,
    required this.signature,
  });

  final int userId;
  final String nickname;
  final String avatarUrl;
  final String signature;
}
