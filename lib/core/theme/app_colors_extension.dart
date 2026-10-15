import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Theme extension carrying the brand-specific semantic colors that aren't
/// covered by Material 3's [ColorScheme] (rating star, discount badge,
/// shadow tints, etc.).
///
/// Using a [ThemeExtension] keeps these tokens reachable through
/// `Theme.of(context).extension<AppSemanticColors>()` so they automatically
/// switch with the active theme.
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.ratingStar,
    required this.discountBadge,
    required this.success,
    required this.error,
    required this.shadowLight,
    required this.shadowDark,
  });

  final Color ratingStar;
  final Color discountBadge;
  final Color success;
  final Color error;

  /// Shadow tint used over light surfaces.
  final Color shadowLight;

  /// Shadow tint used over dark surfaces.
  final Color shadowDark;

  static const AppSemanticColors light = AppSemanticColors(
    ratingStar: AppColors.ratingStar,
    discountBadge: AppColors.discountBadge,
    success: AppColors.success,
    error: AppColors.error,
    shadowLight: Color(0x14000000), // 8% black
    shadowDark: Color(0x33000000),  // 20% black
  );

  static const AppSemanticColors dark = AppSemanticColors(
    ratingStar: AppColors.ratingStar,
    discountBadge: AppColors.discountBadge,
    success: Color(0xFF34D399),
    error: Color(0xFFF87171),
    shadowLight: Color(0x66000000), // 40% black
    shadowDark: Color(0x99000000),  // 60% black
  );

  @override
  AppSemanticColors copyWith({
    Color? ratingStar,
    Color? discountBadge,
    Color? success,
    Color? error,
    Color? shadowLight,
    Color? shadowDark,
  }) {
    return AppSemanticColors(
      ratingStar: ratingStar ?? this.ratingStar,
      discountBadge: discountBadge ?? this.discountBadge,
      success: success ?? this.success,
      error: error ?? this.error,
      shadowLight: shadowLight ?? this.shadowLight,
      shadowDark: shadowDark ?? this.shadowDark,
    );
  }

  @override
  AppSemanticColors lerp(
    ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      ratingStar: Color.lerp(ratingStar, other.ratingStar, t)!,
      discountBadge: Color.lerp(discountBadge, other.discountBadge, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      shadowLight: Color.lerp(shadowLight, other.shadowLight, t)!,
      shadowDark: Color.lerp(shadowDark, other.shadowDark, t)!,
    );
  }
}

/// Sugar extension on [BuildContext] so screens can write
/// `context.semanticColors.ratingStar` instead of digging through
/// `Theme.of(context).extension<AppSemanticColors>()`.
extension AppSemanticColorsX on BuildContext {
  AppSemanticColors get semanticColors {
    final ext = Theme.of(this).extension<AppSemanticColors>();
    return ext ?? AppSemanticColors.light;
  }
}