enum FixtureMode {
  loading,
  data,
  empty,
  error;

  static FixtureMode fromQuery(String? value) {
    for (final mode in FixtureMode.values) {
      if (mode.name == value) return mode;
    }
    return FixtureMode.data;
  }
}

extension FixtureModeQuery on FixtureMode {
  String get queryValue => name;
}
