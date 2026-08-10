import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class ScopifyIconAction extends StatelessWidget {
  const ScopifyIconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.active = false,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: active ? AppTokens.accent : AppTokens.textSecondary,
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}
