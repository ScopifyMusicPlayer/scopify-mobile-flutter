import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';
import 'package:scopify_mobile/pages/home/home_fixture.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'home_content_provider.g.dart';

@riverpod
AsyncValue<HomeContent> homeContent(Ref ref, FixtureMode mode) {
  return switch (mode) {
    FixtureMode.live => throw StateError(
      'Live content uses liveHomeContentProvider.',
    ),
    FixtureMode.loading => const AsyncLoading<HomeContent>(),
    FixtureMode.data => AsyncData<HomeContent>(homeFixture),
    FixtureMode.empty => const AsyncData<HomeContent>(
      HomeContent(
        shortcuts: <HomePlaylist>[],
        recommendations: <HomePlaylist>[],
      ),
    ),
    FixtureMode.error => AsyncError<HomeContent>(
      StateError('Home fixture failure'),
      StackTrace.empty,
    ),
  };
}
