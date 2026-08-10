import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';

final homeFixture = HomeContent(
  shortcuts: playlistFixtures.map(_toHomePlaylist).toList(growable: false),
  recommendations: playlistFixtures
      .map(_toHomePlaylist)
      .toList(growable: false),
);

HomePlaylist _toHomePlaylist(PlaylistFixture playlist) => HomePlaylist(
  id: playlist.id,
  title: playlist.title,
  subtitle: playlist.subtitle,
  description: playlist.description,
  artworkSeed: playlist.artworkSeed,
);
