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
          AsyncValue<List<SearchPlaylistResult>>,
          AsyncValue<List<SearchPlaylistResult>>,
          AsyncValue<List<SearchPlaylistResult>>
        >
    with $Provider<AsyncValue<List<SearchPlaylistResult>>> {
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
  $ProviderElement<AsyncValue<List<SearchPlaylistResult>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<SearchPlaylistResult>> create(Ref ref) {
    final argument = this.argument as FixtureMode;
    return searchContent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<SearchPlaylistResult>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<SearchPlaylistResult>>>(value),
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

String _$searchContentHash() => r'e0d12acc1f29ad878372802c95b02897b6e07abb';

final class SearchContentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<List<SearchPlaylistResult>>,
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
