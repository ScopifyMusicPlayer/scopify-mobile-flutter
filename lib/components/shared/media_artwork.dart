import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

class MediaArtwork extends StatelessWidget {
  const MediaArtwork({
    required this.seed,
    this.circular = false,
    this.shadow = false,
    this.semanticLabel,
    super.key,
  });

  final String seed;
  final bool circular;
  final bool shadow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final palette = _ArtworkPalette.fromSeed(seed);
    final shape = circular ? BoxShape.circle : BoxShape.rectangle;
    final borderRadius = circular ? null : AppTokens.radiusMedium;

    return Semantics(
      image: true,
      label: semanticLabel ?? '专辑封面',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadow ? AppTokens.artworkShadow : null,
          shape: shape,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(999),
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[palette.primary, palette.secondary],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    right: -22,
                    top: -24,
                    child: _BlurredDisc(color: palette.highlight, size: 98),
                  ),
                  Positioned(
                    bottom: -34,
                    left: -20,
                    child: _BlurredDisc(color: palette.shadow, size: 112),
                  ),
                  Center(
                    child: Transform.rotate(
                      angle: palette.rotation,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.62),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlurredDisc extends StatelessWidget {
  const _BlurredDisc({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.48),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ArtworkPalette {
  const _ArtworkPalette({
    required this.primary,
    required this.secondary,
    required this.highlight,
    required this.shadow,
    required this.rotation,
  });

  final Color primary;
  final Color secondary;
  final Color highlight;
  final Color shadow;
  final double rotation;

  factory _ArtworkPalette.fromSeed(String seed) {
    final index = seed.codeUnits.fold<int>(0, (value, unit) => value + unit);
    final palettes = <List<Color>>[
      const <Color>[Color(0xFF1E554D), Color(0xFF0E2D2B), Color(0xFFB0F2C2)],
      const <Color>[Color(0xFF684D22), Color(0xFF2D1E0A), Color(0xFFF5D386)],
      const <Color>[Color(0xFF273560), Color(0xFF11182F), Color(0xFF9AB8FF)],
      const <Color>[Color(0xFF673D55), Color(0xFF26131F), Color(0xFFFFB2C8)],
      const <Color>[Color(0xFF45502A), Color(0xFF18200D), Color(0xFFE2F8A6)],
    ];
    final palette = palettes[index % palettes.length];
    return _ArtworkPalette(
      primary: palette[0],
      secondary: palette[1],
      highlight: palette[2],
      shadow: palette[1],
      rotation: (index % 8) * math.pi / 16,
    );
  }
}
