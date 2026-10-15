import 'package:flutter/material.dart';

/// Brand-level color tokens that don't fit into the Material 3 ColorScheme
/// (e.g. accent colors used for marketing surfaces, semantic tokens that
/// are not covered by [ColorScheme.error]/[ColorScheme.tertiary], etc.).
///
/// Use the Material 3 [ColorScheme] for everything else via
/// `Theme.of(context).colorScheme`. Per-status tonal tweaks live in
/// [AppSemanticColors].
class AppColors {
  AppColors._();

  // Brand ---------------------------------------------------------------------
  static const Color primary = Color(0xFF2563EB);        // Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);

  static const Color secondary = Color(0xFFF97316);      // Energetic Coral
  static const Color secondaryLight = Color(0xFFFFEDD5);

  // Status --------------------------------------------------------------------
  static const Color ratingStar = Color(0xFFF59E0B);      // Amber
  static const Color discountBadge = Color(0xFFDC2626);   // Red
  static const Color success = Color(0xFF10B981);         // Emerald
  static const Color error = Color(0xFFEF4444);           // Red

  // Surfaces (legacy aliases; prefer ColorScheme.surface / surfaceContainer)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  // Typography (legacy aliases; prefer ColorScheme.onSurface / onSurfaceVariant)
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}