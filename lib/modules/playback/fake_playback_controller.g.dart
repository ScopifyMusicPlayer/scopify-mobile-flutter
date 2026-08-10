// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fake_playback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FakePlayback)
final fakePlaybackProvider = FakePlaybackProvider._();

final class FakePlaybackProvider
    extends $NotifierProvider<FakePlayback, FakePlaybackState> {
  FakePlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakePlaybackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakePlaybackHash();

  @$internal
  @override
  FakePlayback create() => FakePlayback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakePlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakePlaybackState>(value),
    );
  }
}

String _$fakePlaybackHash() => r'b7dfdf634c19c0f6a185fa56397a6e17c3c49737';

abstract class _$FakePlayback extends $Notifier<FakePlaybackState> {
  FakePlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FakePlaybackState, FakePlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FakePlaybackState, FakePlaybackState>,
              FakePlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
