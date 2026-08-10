// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchContent)
final searchContentProvider = SearchContentFamily._();

final class SearchContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlaylistFixture>>,
          AsyncValue<List<PlaylistFixture>>,
          AsyncValue<List<PlaylistFixture>>
        >
    with $Provider<AsyncValue<List<PlaylistFixture>>> {
  SearchContentProvider._({
    required SearchContentFamily super.from,
    required FixtureMode super.argument,
  }) : super(
         retry: null,
         name: r'searchContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchContentHash();

  @override
  String toString() {
    return r'searchContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<PlaylistFixture>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<PlaylistFixture>> create(Ref ref) {
    final argument = this.argument as FixtureMode;
    return searchContent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<PlaylistFixture>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<PlaylistFixture>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchContentHash() => r'b8c3d2173623a22733c73f57f6f48dfa6bca4961';

final class SearchContentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<PlaylistFixture>>,
          FixtureMode
        > {
  SearchContentFamily._()
    : super(
        retry: null,
        name: r'searchContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchContentProvider call(FixtureMode mode) =>
      SearchContentProvider._(argument: mode, from: this);

  @override
  String toString() => r'searchContentProvider';
}
