import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'search_content_provider.g.dart';

@riverpod
AsyncValue<List<PlaylistFixture>> searchContent(Ref ref, FixtureMode mode) {
  return switch (mode) {
    FixtureMode.loading => const AsyncLoading<List<PlaylistFixture>>(),
    FixtureMode.data => AsyncData<List<PlaylistFixture>>(playlistFixtures),
    FixtureMode.empty => const AsyncData<List<PlaylistFixture>>(
      <PlaylistFixture>[],
    ),
    FixtureMode.error => AsyncError<List<PlaylistFixture>>(
      StateError('Search fixture failure'),
      StackTrace.empty,
    ),
  };
}
