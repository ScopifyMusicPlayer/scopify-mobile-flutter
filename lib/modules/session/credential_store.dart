import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSessionCredential {
  const StoredSessionCredential({
    required this.cookie,
    required this.endpointId,
  });

  final String cookie;
  final String endpointId;
}

abstract interface class CredentialStore {
  Future<void> clear();

  Future<StoredSessionCredential?> read();

  Future<void> save(StoredSessionCredential credential);
}

class SecureCredentialStore implements CredentialStore {
  SecureCredentialStore({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const _credentialKey = 'scopify.music.session.v1';
  static const _schemaVersion = 1;

  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.delete(key: _credentialKey);

  @override
  Future<StoredSessionCredential?> read() async {
    final encoded = await _storage.read(key: _credentialKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic> ||
          decoded['schemaVersion'] != _schemaVersion ||
          decoded['cookie'] is! String ||
          decoded['endpointId'] is! String) {
        await clear();
        return null;
      }
      final cookie = decoded['cookie']! as String;
      final endpointId = decoded['endpointId']! as String;
      if (cookie.isEmpty || endpointId.isEmpty) {
        await clear();
        return null;
      }
      return StoredSessionCredential(cookie: cookie, endpointId: endpointId);
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(StoredSessionCredential credential) {
    return _storage.write(
      key: _credentialKey,
      value: jsonEncode(<String, Object>{
        'schemaVersion': _schemaVersion,
        'cookie': credential.cookie,
        'endpointId': credential.endpointId,
      }),
    );
  }
}

final credentialStoreProvider = Provider<CredentialStore>(
  (ref) => SecureCredentialStore(),
);
