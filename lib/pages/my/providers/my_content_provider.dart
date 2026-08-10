import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'my_content_provider.g.dart';

class MyFixture {
  const MyFixture({required this.playlists});

  final List<PlaylistFixture> playlists;
}

final myFixture = MyFixture(playlists: playlistFixtures);

@riverpod
AsyncValue<MyFixture> myContent(Ref ref, FixtureMode mode) {
  return switch (mode) {
    FixtureMode.loading => const AsyncLoading<MyFixture>(),
    FixtureMode.data => AsyncData<MyFixture>(myFixture),
    FixtureMode.empty => const AsyncData<MyFixture>(
      MyFixture(playlists: <PlaylistFixture>[]),
    ),
    FixtureMode.error => AsyncError<MyFixture>(
      StateError('My fixture failure'),
      StackTrace.empty,
    ),
  };
}
