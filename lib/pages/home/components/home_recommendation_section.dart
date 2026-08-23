import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/scopify_media_card.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';

class HomeRecommendationSection extends StatelessWidget {
  const HomeRecommendationSection({
    required this.playlists,
    required this.onOpen,
    super.key,
  });

  final List<HomePlaylist> playlists;
  final ValueChanged<HomePlaylist> onOpen;

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
            child: ScopifyMediaCard(
              title: playlist.title,
              subtitle: playlist.subtitle,
              artworkSeed: playlist.artworkSeed,
              onTap: () => onOpen(playlist),
            ),
          );
        },
      ),
    );
  }
}
