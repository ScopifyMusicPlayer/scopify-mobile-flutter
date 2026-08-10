import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class HomeFixture {
  const HomeFixture({required this.shortcuts, required this.recommendations});

  final List<PlaylistFixture> shortcuts;
  final List<PlaylistFixture> recommendations;
}

final homeFixture = HomeFixture(
  shortcuts: playlistFixtures,
  recommendations: playlistFixtures,
);
