import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/pages/search/search_result.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'search_content_provider.g.dart';

@riverpod
AsyncValue<List<SearchPlaylistResult>> searchContent(
  Ref ref,
  FixtureMode mode,
) {
  final fixtureResults = playlistFixtures
      .map(SearchPlaylistResult.fromFixture)
      .toList(growable: false);
  return switch (mode) {
    FixtureMode.live => const AsyncData<List<SearchPlaylistResult>>(
      <SearchPlaylistResult>[],
    ),
    FixtureMode.loading => const AsyncLoading<List<SearchPlaylistResult>>(),
    FixtureMode.data => AsyncData<List<SearchPlaylistResult>>(fixtureResults),
    FixtureMode.empty => const AsyncData<List<SearchPlaylistResult>>(
      <SearchPlaylistResult>[],
    ),
    FixtureMode.error => AsyncError<List<SearchPlaylistResult>>(
      StateError('Search fixture failure'),
      StackTrace.empty,
    ),
  };
}
