import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';
import 'package:scopify_mobile/components/shared/media_artwork.dart';
import 'package:scopify_mobile/pages/search/search_result.dart';

class SearchResultList extends StatelessWidget {
  const SearchResultList({
    required this.results,
    required this.onOpen,
    super.key,
  });

  final List<SearchPlaylistResult> results;
  final ValueChanged<SearchPlaylistResult> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(indent: 76),
      itemBuilder: (context, index) {
        final result = results[index];
        return InkWell(
          onTap: () => onOpen(result),
          borderRadius: AppTokens.radiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTokens.space8),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 60,
                  child: MediaArtwork(seed: result.artworkSeed),
                ),
                const SizedBox(width: AppTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        result.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTokens.space4),
                      Text(
                        result.subtitle,
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
          ),
        );
      },
    );
  }
}
