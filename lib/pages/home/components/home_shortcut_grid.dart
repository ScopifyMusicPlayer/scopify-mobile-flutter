import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/pages/home/home_content.dart';

class HomeShortcutGrid extends StatelessWidget {
  const HomeShortcutGrid({
    required this.playlists,
    required this.onOpen,
    super.key,
  });

  final List<HomePlaylist> playlists;
  final ValueChanged<HomePlaylist> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 64,
        crossAxisSpacing: AppTokens.space8,
        mainAxisSpacing: AppTokens.space8,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Material(
          color: AppTokens.surfaceInteractive,
          borderRadius: AppTokens.radiusSmall,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onOpen(playlist),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 64,
                  child: MediaArtwork(seed: playlist.artworkSeed),
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Text(
                    playlist.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: AppTokens.space8),
              ],
            ),
          ),
        );
      },
    );
  }
}
