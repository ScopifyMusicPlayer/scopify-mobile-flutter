import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:scopify_mobile/app/theme/app_motion.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class ScopifyLoadingState extends StatelessWidget {
  const ScopifyLoadingState({this.rows = 4, super.key});

  final int rows;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ListView.separated(
      padding: const EdgeInsets.all(AppTokens.space16),
      itemCount: rows,
      separatorBuilder: (_, _) => const SizedBox(height: AppTokens.space12),
      itemBuilder: (context, index) {
        final line = Row(
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppTokens.surfaceInteractive,
                borderRadius: AppTokens.radiusSmall,
              ),
            ),
            const SizedBox(width: AppTokens.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: index.isEven ? 160 : 112,
                    height: 14,
                    color: AppTokens.surfaceInteractive,
                  ),
                  const SizedBox(height: AppTokens.space8),
                  Container(
                    width: 84,
                    height: 10,
                    color: AppTokens.surfaceSoft,
                  ),
                ],
              ),
            ),
          ],
        );
        return reduceMotion
            ? line
            : line
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fade(begin: 0.36, end: 0.86, duration: AppMotion.slow);
      },
    );
  }
}

class ScopifyEmptyState extends StatelessWidget {
  const ScopifyEmptyState({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.queue_music_rounded,
              color: AppTokens.textTertiary,
              size: 40,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: AppTokens.space16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ScopifyErrorState extends StatelessWidget {
  const ScopifyErrorState({
    required this.title,
    required this.description,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String description;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              color: AppTokens.warning,
              size: 40,
            ),
            const SizedBox(height: AppTokens.space16),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
