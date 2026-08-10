// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_home_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LiveHomeContent)
final liveHomeContentProvider = LiveHomeContentProvider._();

final class LiveHomeContentProvider
    extends $AsyncNotifierProvider<LiveHomeContent, HomeContent> {
  LiveHomeContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveHomeContentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveHomeContentHash();

  @$internal
  @override
  LiveHomeContent create() => LiveHomeContent();
}

String _$liveHomeContentHash() => r'14bbbee312ed6b2578aafb3bc7029690c5d53984';

abstract class _$LiveHomeContent extends $AsyncNotifier<HomeContent> {
  FutureOr<HomeContent> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<HomeContent>, HomeContent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<HomeContent>, HomeContent>,
              AsyncValue<HomeContent>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
