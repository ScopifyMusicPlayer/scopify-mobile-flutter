class BackendEndpoint {
  const BackendEndpoint._(this.uri);

  /// Android Emulator reaches the developer machine through this host.
  static final defaultValue = BackendEndpoint._(
    Uri.parse('http://10.0.2.2:3838'),
  );

  final Uri uri;

  String get baseUrl => uri.toString();

  String get id => uri.toString();

  static BackendEndpoint parse(String raw) {
    final trimmed = raw.trim();
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null ||
        !parsed.hasAuthority ||
        (parsed.scheme != 'http' && parsed.scheme != 'https') ||
        parsed.host.isEmpty ||
        parsed.hasQuery ||
        parsed.hasFragment) {
      throw const FormatException('请输入有效的 http 或 https 后端地址。');
    }
    if (parsed.scheme == 'http' && !_isLocalOrPrivateHost(parsed.host)) {
      throw const FormatException('HTTP 只允许 localhost 或私有网络 IP；公网地址请使用 HTTPS。');
    }

    final normalizedPath = parsed.path.isEmpty || parsed.path == '/'
        ? ''
        : parsed.path.replaceFirst(RegExp(r'/+$'), '');
    return BackendEndpoint._(
      parsed.replace(path: normalizedPath, query: null, fragment: null),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BackendEndpoint && other.uri == uri;

  @override
  int get hashCode => uri.hashCode;

  @override
  String toString() => baseUrl;

  static bool _isLocalOrPrivateHost(String host) {
    final normalized = host.toLowerCase();
    if (normalized == 'localhost' || normalized == '::1') return true;
    final ipv4 = normalized.split('.');
    if (ipv4.length == 4) {
      final octets = ipv4.map(int.tryParse).toList(growable: false);
      if (octets.any((octet) => octet == null || octet < 0 || octet > 255)) {
        return false;
      }
      final first = octets[0]!;
      final second = octets[1]!;
      return first == 10 ||
          first == 127 ||
          (first == 172 && second >= 16 && second <= 31) ||
          (first == 192 && second == 168);
    }
    return normalized.startsWith('fc') || normalized.startsWith('fd');
  }
}
