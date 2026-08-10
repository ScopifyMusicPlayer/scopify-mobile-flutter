import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/pages/playlist/playlist_fixture.dart';

class MySectionContent extends StatelessWidget {
  const MySectionContent({
    required this.playlists,
    required this.kind,
    required this.onOpen,
    super.key,
  });

  final List<PlaylistFixture> playlists;
  final String kind;
  final ValueChanged<PlaylistFixture> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space16,
        AppTokens.space16,
        AppTokens.space16,
        AppTokens.space32,
      ),
      itemCount: playlists.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return InkWell(
          borderRadius: AppTokens.radiusMedium,
          onTap: () => onOpen(playlist),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 64,
                child: MediaArtwork(seed: playlist.artworkSeed),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      playlist.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Text(
                      '$kind · ${playlist.subtitle}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTokens.textTertiary,
              ),
            ],
          ),
        );
      },
    );
  }
}
