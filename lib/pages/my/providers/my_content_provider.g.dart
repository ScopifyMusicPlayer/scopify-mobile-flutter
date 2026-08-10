// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(myContent)
final myContentProvider = MyContentFamily._();

final class MyContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<MyFixture>,
          AsyncValue<MyFixture>,
          AsyncValue<MyFixture>
        >
    with $Provider<AsyncValue<MyFixture>> {
  MyContentProvider._({
    required MyContentFamily super.from,
    required FixtureMode super.argument,
  }) : super(
         retry: null,
         name: r'myContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myContentHash();

  @override
  String toString() {
    return r'myContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<MyFixture>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MyFixture> create(Ref ref) {
    final argument = this.argument as FixtureMode;
    return myContent(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MyFixture> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MyFixture>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MyContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myContentHash() => r'b9db9a91c73930910db036c586daa268be6f285b';

final class MyContentFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<MyFixture>, FixtureMode> {
  MyContentFamily._()
    : super(
        retry: null,
        name: r'myContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MyContentProvider call(FixtureMode mode) =>
      MyContentProvider._(argument: mode, from: this);

  @override
  String toString() => r'myContentProvider';
}
