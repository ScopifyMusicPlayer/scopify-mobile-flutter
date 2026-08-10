// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(livePlaylistSearch)
final livePlaylistSearchProvider = LivePlaylistSearchFamily._();

final class LivePlaylistSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchPlaylistResult>>,
          List<SearchPlaylistResult>,
          FutureOr<List<SearchPlaylistResult>>
        >
    with
        $FutureModifier<List<SearchPlaylistResult>>,
        $FutureProvider<List<SearchPlaylistResult>> {
  LivePlaylistSearchProvider._({
    required LivePlaylistSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'livePlaylistSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$livePlaylistSearchHash();

  @override
  String toString() {
    return r'livePlaylistSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SearchPlaylistResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchPlaylistResult>> create(Ref ref) {
    final argument = this.argument as String;
    return livePlaylistSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LivePlaylistSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$livePlaylistSearchHash() =>
    r'270309ec6a7b696d2aedf016aa5a942d6f856949';

final class LivePlaylistSearchFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SearchPlaylistResult>>,
          String
        > {
  LivePlaylistSearchFamily._()
    : super(
        retry: null,
        name: r'livePlaylistSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LivePlaylistSearchProvider call(String query) =>
      LivePlaylistSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'livePlaylistSearchProvider';
}
