import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/shared/fixtures/fixture_mode.dart';

part 'my_content_provider.g.dart';

class MyFixture {
  const MyFixture({required this.playlists});

  final List<AccountPlaylist> playlists;
}

final myFixture = MyFixture(
  playlists: playlistFixtures
      .map(
        (playlist) => AccountPlaylist(
          id: playlist.id,
          name: playlist.title,
          creatorName: playlist.subtitle,
          trackCount: playlist.tracks.length,
          artworkUrl: '',
          isOwnedByCurrentUser: true,
        ),
      )
      .toList(growable: false),
);

@riverpod
AsyncValue<MyFixture> myContent(Ref ref, FixtureMode mode) {
  return switch (mode) {
    FixtureMode.live => AsyncData<MyFixture>(myFixture),
    FixtureMode.loading => const AsyncLoading<MyFixture>(),
    FixtureMode.data => AsyncData<MyFixture>(myFixture),
    FixtureMode.empty => const AsyncData<MyFixture>(
      MyFixture(playlists: <AccountPlaylist>[]),
    ),
    FixtureMode.error => AsyncError<MyFixture>(
      StateError('My fixture failure'),
      StackTrace.empty,
    ),
  };
}
