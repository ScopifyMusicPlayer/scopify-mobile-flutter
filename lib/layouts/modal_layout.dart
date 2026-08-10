import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class ModalLayout extends StatelessWidget {
  const ModalLayout({
    required this.title,
    required this.child,
    required this.onClose,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTokens.surfaceRaised,
        border: Border.all(color: AppTokens.divider),
        borderRadius: AppTokens.radiusLarge,
        boxShadow: AppTokens.floatingShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: '关闭',
                  onPressed: onClose,
                ),
              ],
            ),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: AppTokens.space4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: AppTokens.space16),
            child,
          ],
        ),
      ),
    );
  }
}
