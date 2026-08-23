import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';

/// Shared media-card geometry for Web GridCard-style content.
class ScopifyMediaCard extends StatelessWidget {
  const ScopifyMediaCard({
    required this.title,
    required this.artworkSeed,
    this.subtitle,
    this.onTap,
    this.circularArtwork = false,
    super.key,
  });

  final String title;
  final String artworkSeed;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool circularArtwork;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: AppTokens.radiusMedium,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MediaArtwork(
                seed: artworkSeed,
                circular: circularArtwork,
                shadow: true,
              ),
              const SizedBox(height: AppTokens.space12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: AppTokens.space4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
