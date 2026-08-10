import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class HomeRecommendationSection extends StatelessWidget {
  const HomeRecommendationSection({
    required this.playlists,
    required this.onOpen,
    super.key,
  });

  final List<PlaylistFixture> playlists;
  final ValueChanged<PlaylistFixture> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 226,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppTokens.space12),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return SizedBox(
            width: 148,
            child: InkWell(
              borderRadius: AppTokens.radiusMedium,
              onTap: () => onOpen(playlist),
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MediaArtwork(seed: playlist.artworkSeed, shadow: true),
                    const SizedBox(height: AppTokens.space12),
                    Text(
                      playlist.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      playlist.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
