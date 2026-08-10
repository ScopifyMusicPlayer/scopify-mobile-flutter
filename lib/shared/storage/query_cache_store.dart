import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class QueryCacheKey {
  const QueryCacheKey({
    required this.endpointId,
    required this.accountId,
    required this.scope,
    required this.query,
    required this.parameters,
    required this.schemaVersion,
  });

  final String endpointId;
  final String accountId;
  final String scope;
  final String query;
  final Map<String, Object?> parameters;
  final int schemaVersion;

  String get value => jsonEncode(<String, Object?>{
    'accountId': accountId,
    'endpointId': endpointId,
    'parameters': _canonicalize(parameters),
    'query': query,
    'schemaVersion': schemaVersion,
    'scope': scope,
  });

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final entries =
          value.entries
              .map(
                (entry) =>
                    MapEntry(entry.key.toString(), _canonicalize(entry.value)),
              )
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));
      return Map<String, Object?>.fromEntries(entries);
    }
    if (value is List) return value.map(_canonicalize).toList();
    return value;
  }
}

class QueryCachePolicy {
  const QueryCachePolicy({required this.freshFor, required this.maxAge});

  final Duration freshFor;
  final Duration maxAge;
}

class QueryCacheEntry {
  const QueryCacheEntry({
    required this.payload,
    required this.freshUntil,
    required this.expiresAt,
  });

  final Map<String, Object?> payload;
  final DateTime freshUntil;
  final DateTime expiresAt;

  bool isFreshAt(DateTime now) => !now.isAfter(freshUntil);
}

/// The single persistent cache table for explicitly approved query data.
///
/// Callers only cross this interface: read an eligible entry, write a result,
/// or clear a scope. SQL, expiry deletion and LRU housekeeping remain local.
class QueryCacheStore {
  QueryCacheStore({
    DatabaseFactory? factory,
    Future<String> Function()? databasePath,
    DateTime Function()? clock,
  }) : _databaseFactory = factory,
       _databasePath = databasePath ?? _defaultDatabasePath,
       _clock = clock ?? DateTime.now;

  static const _databaseName = 'scopify_query_cache.db';
  static const _table = 'query_cache';

  final DatabaseFactory? _databaseFactory;
  final Future<String> Function() _databasePath;
  final DateTime Function() _clock;
  Future<Database>? _opening;

  Future<QueryCacheEntry?> read(QueryCacheKey key) async {
    final database = await _open();
    final now = _clock();
    final rows = await database.query(
      _table,
      columns: const <String>['payload_json', 'fresh_until', 'expires_at'],
      where: 'cache_key = ?',
      whereArgs: <Object?>[key.value],
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final row = rows.single;
    final expiresAt = _fromEpoch(row['expires_at']);
    if (!now.isBefore(expiresAt)) {
      await database.delete(
        _table,
        where: 'cache_key = ?',
        whereArgs: <Object?>[key.value],
      );
      return null;
    }

    await database.update(
      _table,
      <String, Object?>{'last_accessed_at': now.millisecondsSinceEpoch},
      where: 'cache_key = ?',
      whereArgs: <Object?>[key.value],
    );
    final payload = jsonDecode(row['payload_json']! as String);
    if (payload is! Map) {
      await delete(key);
      return null;
    }
    return QueryCacheEntry(
      payload: Map<String, Object?>.from(payload),
      freshUntil: _fromEpoch(row['fresh_until']),
      expiresAt: expiresAt,
    );
  }

  Future<void> write({
    required QueryCacheKey key,
    required Map<String, Object?> payload,
    required QueryCachePolicy policy,
  }) async {
    if (policy.freshFor > policy.maxAge) {
      throw ArgumentError.value(
        policy,
        'policy',
        'freshFor cannot exceed maxAge.',
      );
    }
    final database = await _open();
    final now = _clock();
    await database.insert(_table, <String, Object?>{
      'cache_key': key.value,
      'endpoint_id': key.endpointId,
      'account_id': key.accountId,
      'scope': key.scope,
      'payload_json': jsonEncode(payload),
      'fresh_until': now.add(policy.freshFor).millisecondsSinceEpoch,
      'expires_at': now.add(policy.maxAge).millisecondsSinceEpoch,
      'last_accessed_at': now.millisecondsSinceEpoch,
      'schema_version': key.schemaVersion,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(QueryCacheKey key) async {
    final database = await _open();
    await database.delete(
      _table,
      where: 'cache_key = ?',
      whereArgs: <Object?>[key.value],
    );
  }

  Future<void> clearScope({
    required String endpointId,
    required String scope,
    required String accountId,
  }) async {
    final database = await _open();
    await database.delete(
      _table,
      where: 'endpoint_id = ? AND scope = ? AND account_id = ?',
      whereArgs: <Object?>[endpointId, scope, accountId],
    );
  }

  Future<void> close() async {
    final database = _opening == null ? null : await _opening;
    await database?.close();
  }

  Future<Database> _open() {
    return _opening ??= () async {
      final databasePath = await _databasePath();
      final factory = _databaseFactory ?? databaseFactory;
      return factory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE $_table (
                cache_key TEXT PRIMARY KEY,
                endpoint_id TEXT NOT NULL,
                account_id TEXT NOT NULL,
                scope TEXT NOT NULL,
                payload_json TEXT NOT NULL,
                fresh_until INTEGER NOT NULL,
                expires_at INTEGER NOT NULL,
                last_accessed_at INTEGER NOT NULL,
                schema_version INTEGER NOT NULL
              )
            ''');
            await database.execute(
              'CREATE INDEX query_cache_scope_idx '
              'ON $_table(endpoint_id, scope, account_id)',
            );
          },
        ),
      );
    }();
  }

  DateTime _fromEpoch(Object? value) {
    if (value is! int) throw StateError('Cache timestamp was invalid.');
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static Future<String> _defaultDatabasePath() async {
    final root = await getDatabasesPath();
    return path.join(root, _databaseName);
  }
}

final queryCacheStoreProvider = Provider<QueryCacheStore>((ref) {
  final store = QueryCacheStore();
  ref.onDispose(() {
    store.close();
  });
  return store;
});
