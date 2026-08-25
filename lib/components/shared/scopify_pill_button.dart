import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_motion.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

enum ScopifyPillButtonVariant { brand, outline, soft }

/// The shared long-action seam for Web's brand, outline and soft buttons.
///
/// Callers provide a label and one action; geometry, hit target, colors and
/// pressed feedback stay aligned with the cross-platform design contract.
class ScopifyPillButton extends StatelessWidget {
  const ScopifyPillButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ScopifyPillButtonVariant.brand,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ScopifyPillButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final background = switch (variant) {
      ScopifyPillButtonVariant.brand => AppTokens.accent,
      ScopifyPillButtonVariant.outline => Colors.transparent,
      ScopifyPillButtonVariant.soft => AppTokens.surfaceInteractive,
    };
    final foreground = switch (variant) {
      ScopifyPillButtonVariant.brand => AppTokens.canvas,
      ScopifyPillButtonVariant.outline => AppTokens.textPrimary,
      ScopifyPillButtonVariant.soft => AppTokens.textPrimary,
    };
    final border = variant == ScopifyPillButtonVariant.outline
        ? const BorderSide(color: AppTokens.divider)
        : BorderSide.none;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: enabled ? 1 : 0.52,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: AppTokens.radiusPill,
            side: border,
          ),
          elevation: variant == ScopifyPillButtonVariant.brand ? 2 : 0,
          shadowColor: AppTokens.accent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: AppTokens.radiusPill,
            splashColor: foreground.withValues(alpha: 0.12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space20,
                  vertical: AppTokens.space12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      )
                    else if (icon != null)
                      Icon(icon, size: 18, color: foreground),
                    if (isLoading || icon != null)
                      const SizedBox(width: AppTokens.space8),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
