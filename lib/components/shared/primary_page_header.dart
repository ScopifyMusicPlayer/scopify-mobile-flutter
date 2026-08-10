import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class PrimaryPageHeader extends StatelessWidget {
  const PrimaryPageHeader({
    required this.title,
    this.trailing,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space8,
        AppTokens.space8,
        AppTokens.space8,
        AppTokens.space12,
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: '打开菜单',
            icon: const Icon(Icons.menu_rounded),
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 48, child: trailing),
        ],
      ),
    );
  }
}
