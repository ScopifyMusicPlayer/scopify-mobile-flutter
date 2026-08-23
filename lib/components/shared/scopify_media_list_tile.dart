import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';

/// Shared transparent media-row geometry for Web SongRow-style lists.
class ScopifyMediaListTile extends StatelessWidget {
  const ScopifyMediaListTile({
    required this.title,
    required this.subtitle,
    required this.artworkSeed,
    this.onTap,
    this.trailing,
    this.isActive = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String artworkSeed;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: isActive ? AppTokens.accent : AppTokens.textPrimary,
      fontWeight: FontWeight.w600,
    );
    return Material(
      color: Colors.transparent,
      borderRadius: AppTokens.radiusSmall,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusSmall,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space8,
            vertical: AppTokens.space8,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(width: 48, child: MediaArtwork(seed: artworkSeed)),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppTokens.space8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
