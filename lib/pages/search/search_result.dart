import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class SearchPlaylistResult {
  const SearchPlaylistResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.artworkSeed,
    this.artworkUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String artworkSeed;
  final String? artworkUrl;

  factory SearchPlaylistResult.fromFixture(PlaylistFixture fixture) {
    return SearchPlaylistResult(
      id: fixture.id,
      title: fixture.title,
      subtitle: fixture.subtitle,
      artworkSeed: fixture.artworkSeed,
    );
  }
}
