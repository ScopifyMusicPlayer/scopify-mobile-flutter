import 'package:scopify_mobile/modules/playback/media_track.dart';

class PlaylistFixture {
  const PlaylistFixture({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artworkSeed,
    required this.tracks,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String artworkSeed;
  final List<MediaTrack> tracks;
}

const List<PlaylistFixture> playlistFixtures = <PlaylistFixture>[
  PlaylistFixture(
    id: 'daily-mix',
    title: '今日私藏',
    subtitle: '为你准备的新鲜声音',
    description: '从熟悉的旋律出发，绕一点小路，听见今天的新发现。',
    artworkSeed: 'daily-mix',
    tracks: <MediaTrack>[
      MediaTrack(
        id: 'from-the-start',
        title: 'From The Start',
        artist: 'Laufey',
        album: 'Bewitched',
        artworkSeed: 'from-the-start',
        duration: Duration(minutes: 3, seconds: 5),
      ),
      MediaTrack(
        id: 'night-drive',
        title: 'Night Drive',
        artist: 'Mondo Loops',
        album: 'Afterglow',
        artworkSeed: 'night-drive',
        duration: Duration(minutes: 4, seconds: 12),
      ),
      MediaTrack(
        id: 'cafe-slow',
        title: 'Café Slow',
        artist: 'Pale June',
        album: 'City Warmth',
        artworkSeed: 'cafe-slow',
        duration: Duration(minutes: 2, seconds: 48),
      ),
    ],
  ),
  PlaylistFixture(
    id: 'city-pop',
    title: 'City Pop 夜色',
    subtitle: '霓虹灯下的慢速公路',
    description: '柔和鼓机、干净贝斯和一点点不会过期的夜行感。',
    artworkSeed: 'city-pop',
    tracks: <MediaTrack>[
      MediaTrack(
        id: 'plastic-love',
        title: 'Plastic Love',
        artist: 'Mariya Takeuchi',
        album: 'VARIETY',
        artworkSeed: 'plastic-love',
        duration: Duration(minutes: 4, seconds: 55),
      ),
      MediaTrack(
        id: 'windy-summer',
        title: 'Windy Summer',
        artist: 'Kido',
        album: 'Blue Hour',
        artworkSeed: 'windy-summer',
        duration: Duration(minutes: 3, seconds: 36),
      ),
    ],
  ),
  PlaylistFixture(
    id: 'acoustic-morning',
    title: '晨间原声',
    subtitle: '把一天打开得轻一些',
    description: '适合窗边、咖啡和还没被消息打断的清晨。',
    artworkSeed: 'acoustic-morning',
    tracks: <MediaTrack>[
      MediaTrack(
        id: 'bloom',
        title: 'Bloom',
        artist: 'The Paper Kites',
        album: 'Woodland',
        artworkSeed: 'bloom',
        duration: Duration(minutes: 3, seconds: 29),
      ),
      MediaTrack(
        id: 'sunlit-room',
        title: 'Sunlit Room',
        artist: 'Milo Grey',
        album: 'Warm Places',
        artworkSeed: 'sunlit-room',
        duration: Duration(minutes: 3, seconds: 42),
      ),
    ],
  ),
];

PlaylistFixture playlistById(String id) {
  return playlistFixtures.firstWhere(
    (playlist) => playlist.id == id,
    orElse: () => playlistFixtures.first,
  );
}

MediaTrack get demoTrack => playlistFixtures.first.tracks.first;
