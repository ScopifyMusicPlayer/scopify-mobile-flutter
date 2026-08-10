class HomeContent {
  const HomeContent({required this.shortcuts, required this.recommendations});

  final List<HomePlaylist> shortcuts;
  final List<HomePlaylist> recommendations;

  bool get isEmpty => shortcuts.isEmpty && recommendations.isEmpty;

  Map<String, Object?> toJson() => <String, Object?>{
    'shortcuts': shortcuts.map((playlist) => playlist.toJson()).toList(),
    'recommendations': recommendations
        .map((playlist) => playlist.toJson())
        .toList(),
  };

  factory HomeContent.fromJson(Map<String, Object?> json) {
    List<HomePlaylist> playlistsFor(String key) {
      final rawItems = json[key];
      if (rawItems is! List) return const <HomePlaylist>[];
      return rawItems
          .whereType<Map>()
          .map((item) => HomePlaylist.fromJson(Map<String, Object?>.from(item)))
          .toList(growable: false);
    }

    return HomeContent(
      shortcuts: playlistsFor('shortcuts'),
      recommendations: playlistsFor('recommendations'),
    );
  }
}

class HomePlaylist {
  const HomePlaylist({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.artworkSeed,
    this.artworkUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String artworkSeed;
  final String? artworkUrl;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'description': description,
    'artworkSeed': artworkSeed,
    'artworkUrl': artworkUrl,
  };

  factory HomePlaylist.fromJson(Map<String, Object?> json) {
    String text(String key, {String fallback = ''}) =>
        json[key] is String ? json[key]! as String : fallback;
    return HomePlaylist(
      id: text('id'),
      title: text('title', fallback: '未命名歌单'),
      subtitle: text('subtitle', fallback: '为你推荐'),
      description: text('description'),
      artworkSeed: text('artworkSeed', fallback: text('id')),
      artworkUrl: json['artworkUrl'] as String?,
    );
  }
}
