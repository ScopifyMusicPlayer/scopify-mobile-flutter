import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/scopify_media_list_tile.dart';
import 'package:scopify_mobile/pages/account/account_models.dart';

class MySectionContent extends StatelessWidget {
  const MySectionContent({
    required this.playlists,
    required this.kind,
    required this.onOpen,
    super.key,
  });

  final List<AccountPlaylist> playlists;
  final String kind;
  final ValueChanged<AccountPlaylist> onOpen;

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
        return ScopifyMediaListTile(
          title: playlist.name,
          subtitle:
              '$kind · ${playlist.trackCount} 首 · ${playlist.creatorName}',
          artworkSeed: playlist.id,
          onTap: () => onOpen(playlist),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: AppTokens.textTertiary,
          ),
        );
      },
    );
  }
}
