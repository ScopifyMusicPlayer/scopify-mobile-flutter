import 'package:flutter/material.dart';

abstract final class AppTokens {
  static const Color canvas = Color(0xFF000000);
  static const Color surfaceBase = Color(0xFF121212);
  static const Color surfaceDeep = Color(0xFF0F0F0F);
  static const Color surfaceCard = Color(0xFF181818);
  static const Color surfaceRaised = Color(0xFF282828);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF727272);
  static const Color accent = Color(0xFF1ED760);
  static const Color accentHover = Color(0xFF3BE477);
  static const Color danger = Color(0xFFF15B5D);
  static const Color warning = Color(0xFFF5A524);
  static const Color overlay = Color(0xB8000000);
  static const Color divider = Color(0x1AFFFFFF);
  static const Color surfaceSoft = Color(0x0DFFFFFF);
  static const Color surfaceInteractive = Color(0x1AFFFFFF);

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(8));
  static const BorderRadius radiusMedium = BorderRadius.all(
    Radius.circular(12),
  );
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(16));
  static const BorderRadius radiusPill = BorderRadius.all(Radius.circular(999));

  static const List<BoxShadow> artworkShadow = <BoxShadow>[
    BoxShadow(color: Color(0xA6000000), blurRadius: 28, offset: Offset(0, 14)),
  ];

  static const List<BoxShadow> floatingShadow = <BoxShadow>[
    BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8)),
  ];
}
