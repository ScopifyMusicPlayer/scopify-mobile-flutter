import 'package:scopify_mobile/modules/session/credential_store.dart';
import 'package:scopify_mobile/modules/session/session_api.dart';
import 'package:scopify_mobile/modules/session/session_state.dart';

class MemoryCredentialStore implements CredentialStore {
  MemoryCredentialStore({this.credential});

  StoredSessionCredential? credential;

  @override
  Future<void> clear() async {
    credential = null;
  }

  @override
  Future<StoredSessionCredential?> read() async => credential;

  @override
  Future<void> save(StoredSessionCredential credential) async {
    this.credential = credential;
  }
}

class FakeSessionGateway implements SessionGateway {
  FakeSessionGateway({
    this.endpointId = 'http://10.0.2.2:3838',
    this.profile = const SessionProfile(
      userId: 42,
      nickname: '测试用户',
      avatarUrl: '',
      signature: '正在听喜欢的歌',
    ),
    this.error,
  });

  @override
  final String endpointId;

  final SessionProfile profile;
  final Object? error;
  final List<String> validatedCookies = <String>[];
  final List<String> revokedCookies = <String>[];

  @override
  Future<void> revokeCredential(String cookie) async {
    revokedCookies.add(cookie);
  }

  @override
  Future<SessionProfile> validateCredential(String cookie) async {
    validatedCookies.add(cookie);
    if (error case final failure?) throw failure;
    return profile;
  }
}
