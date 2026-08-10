// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foreground_playback_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForegroundPlayback)
final foregroundPlaybackProvider = ForegroundPlaybackProvider._();

final class ForegroundPlaybackProvider
    extends $NotifierProvider<ForegroundPlayback, ForegroundPlaybackState> {
  ForegroundPlaybackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foregroundPlaybackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foregroundPlaybackHash();

  @$internal
  @override
  ForegroundPlayback create() => ForegroundPlayback();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForegroundPlaybackState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForegroundPlaybackState>(value),
    );
  }
}

String _$foregroundPlaybackHash() =>
    r'5baac752cc2c9ad969b130b24fd85be36c8759a9';

abstract class _$ForegroundPlayback extends $Notifier<ForegroundPlaybackState> {
  ForegroundPlaybackState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ForegroundPlaybackState, ForegroundPlaybackState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForegroundPlaybackState, ForegroundPlaybackState>,
              ForegroundPlaybackState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
