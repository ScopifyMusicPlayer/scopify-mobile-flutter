import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class PlayerLayout extends StatelessWidget {
  const PlayerLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTokens.canvas,
          gradient: RadialGradient(
            center: Alignment(-0.62, -0.72),
            radius: 1.25,
            colors: <Color>[
              Color(0xFF285349),
              AppTokens.surfaceBase,
              AppTokens.canvas,
            ],
            stops: <double>[0, 0.52, 1],
          ),
        ),
        child: child,
      ),
    );
  }
}
