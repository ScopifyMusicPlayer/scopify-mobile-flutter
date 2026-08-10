// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_playlist_content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LivePlaylistContent)
final livePlaylistContentProvider = LivePlaylistContentFamily._();

final class LivePlaylistContentProvider
    extends $AsyncNotifierProvider<LivePlaylistContent, PlaylistContent> {
  LivePlaylistContentProvider._({
    required LivePlaylistContentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'livePlaylistContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$livePlaylistContentHash();

  @override
  String toString() {
    return r'livePlaylistContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LivePlaylistContent create() => LivePlaylistContent();

  @override
  bool operator ==(Object other) {
    return other is LivePlaylistContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$livePlaylistContentHash() =>
    r'fc9bdced34980b4089466e61f3f026f81a47e022';

final class LivePlaylistContentFamily extends $Family
    with
        $ClassFamilyOverride<
          LivePlaylistContent,
          AsyncValue<PlaylistContent>,
          PlaylistContent,
          FutureOr<PlaylistContent>,
          String
        > {
  LivePlaylistContentFamily._()
    : super(
        retry: null,
        name: r'livePlaylistContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LivePlaylistContentProvider call(String playlistId) =>
      LivePlaylistContentProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'livePlaylistContentProvider';
}

abstract class _$LivePlaylistContent extends $AsyncNotifier<PlaylistContent> {
  late final _$args = ref.$arg as String;
  String get playlistId => _$args;

  FutureOr<PlaylistContent> build(String playlistId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PlaylistContent>, PlaylistContent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlaylistContent>, PlaylistContent>,
              AsyncValue<PlaylistContent>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
