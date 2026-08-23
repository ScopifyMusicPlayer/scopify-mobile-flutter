import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class DetailLayout extends StatelessWidget {
  const DetailLayout({
    required this.eyebrow,
    required this.body,
    this.trailing,
    super.key,
  });

  final String eyebrow;
  final Widget body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceBase,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space8,
                AppTokens.space8,
                AppTokens.space16,
                AppTokens.space8,
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    onPressed: () => context.pop(),
                    tooltip: '返回',
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      eyebrow,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  SizedBox(width: 48, child: trailing),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
