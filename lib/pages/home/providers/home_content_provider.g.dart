// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeContent)
final homeContentProvider = HomeContentFamily._();

final class HomeContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeFixture>,
          AsyncValue<HomeFixture>,
          AsyncValue<HomeFixture>
        >
    with $Provider<AsyncValue<HomeFixture>> {
  HomeContentProvider._({
    required HomeContentFamily super.from,
    required FixtureMode super.argument,
  }) : super(
         retry: null,
         name: r'homeContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$homeContentHash();

  @override
  String toString() {
    return r'homeContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<HomeFixture>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<HomeFixture> create(Ref ref) {
    final argument = this.argument as FixtureMode;
    return homeContent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<HomeFixture> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<HomeFixture>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HomeContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$homeContentHash() => r'68bfeb6f2eb1082cad6b93a72554a6c125109d0f';

final class HomeContentFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<HomeFixture>, FixtureMode> {
  HomeContentFamily._()
    : super(
        retry: null,
        name: r'homeContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HomeContentProvider call(FixtureMode mode) =>
      HomeContentProvider._(argument: mode, from: this);

  @override
  String toString() => r'homeContentProvider';
}
