import 'package:flutter/material.dart';
import 'package:scopify_mobile/app/theme/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppTokens.accent,
      onPrimary: AppTokens.canvas,
      secondary: AppTokens.accent,
      onSecondary: AppTokens.canvas,
      surface: AppTokens.surfaceBase,
      onSurface: AppTokens.textPrimary,
      error: AppTokens.danger,
      onError: AppTokens.canvas,
    );

    final textTheme = Typography.material2021(platform: TargetPlatform.android)
        .white
        .copyWith(
          displaySmall: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.02,
            letterSpacing: -1.1,
          ),
          headlineSmall: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: -0.6,
          ),
          titleLarge: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
          titleMedium: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
          bodyLarge: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          bodyMedium: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
          labelLarge: const TextStyle(
            color: AppTokens.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          labelMedium: const TextStyle(
            color: AppTokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppTokens.surfaceBase,
      textTheme: textTheme,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: const CardThemeData(
        color: AppTokens.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMedium),
      ),
      dividerTheme: const DividerThemeData(color: AppTokens.divider, space: 1),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppTokens.surfaceDeep,
        indicatorColor: AppTokens.surfaceInteractive,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppTokens.textPrimary
                : AppTokens.textTertiary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppTokens.accent
                : AppTokens.textSecondary,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
        border: OutlineInputBorder(
          borderRadius: AppTokens.radiusSmall,
          borderSide: const BorderSide(color: AppTokens.textTertiary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppTokens.radiusSmall,
          borderSide: const BorderSide(color: AppTokens.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppTokens.radiusSmall,
          borderSide: const BorderSide(color: AppTokens.textPrimary),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.surfaceRaised,
        modalBackgroundColor: AppTokens.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
