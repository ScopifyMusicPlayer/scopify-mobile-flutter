import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_motion.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class ScopifyPlayButton extends StatelessWidget {
  const ScopifyPlayButton({
    required this.isPlaying,
    required this.onPressed,
    this.size = 56,
    this.darkIcon = true,
    super.key,
  });

  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;
  final bool darkIcon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPlaying ? '暂停' : '播放',
      child: Material(
        color: darkIcon ? AppTokens.accent : AppTokens.textPrimary,
        elevation: 5,
        shadowColor: AppTokens.canvas,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  key: ValueKey<bool>(isPlaying),
                  color: darkIcon ? AppTokens.canvas : AppTokens.surfaceBase,
                  size: size * 0.56,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
