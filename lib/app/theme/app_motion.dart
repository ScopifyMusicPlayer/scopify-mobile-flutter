import 'package:flutter/animation.dart';

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 700);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutQuart;
}
