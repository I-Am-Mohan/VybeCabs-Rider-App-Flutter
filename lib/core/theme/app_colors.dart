import 'package:flutter/material.dart';

/// Universal Project Color System
/// Tokens defined according to colors.md specification.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFE64826);
  static const Color primaryHover = Color(0xFFE42202);
  static const Color primaryPressed = Color(0xFFE42202);
  static const Color primaryDisabled = Color(0xFFF0B3A7);
  static const Color primarySoft = Color(0xFFF2DFDD);
  static const Color primarySoft2 = Color(0xFFF2E6E5);
  static const Color primaryOnColor = Color(0xFFFFFFFF);

  // Background
  static const Color background = Color(0xFFFCFCFC);
  static const Color backgroundSecondary = Color(0xFFF8F8F8);
  static const Color backgroundTertiary = Color(0xFFF4F5F6);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF4F5F6);
  static const Color surfaceTertiary = Color(0xFFF0F0EF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceBrand = Color(0xFFF2DFDD);

  // Text
  static const Color textPrimary = Color(0xFF030204);
  static const Color textSecondary = Color(0xFF4B4A4C);
  static const Color textTertiary = Color(0xFF6F6B69);
  static const Color textMuted = Color(0xFF828486);
  static const Color textDisabled = Color(0xFF9A9A9B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE8E9EA);
  static const Color borderSubtle = Color(0xFFECEBEB);
  static const Color borderStrong = Color(0xFFD5D5D7);
  static const Color borderFocus = Color(0xFFE64826);

  // Icons
  static const Color iconPrimary = Color(0xFF252324);
  static const Color iconSecondary = Color(0xFF6F6B69);
  static const Color iconMuted = Color(0xFF828486);
  static const Color iconDisabled = Color(0xFF9A9A9B);
  static const Color iconOnPrimary = Color(0xFFFFFFFF);
  static const Color iconBrand = Color(0xFFE64826);

  // Interactive
  static const Color interactiveDefault = Color(0xFFE64826);
  static const Color interactiveHover = Color(0xFFE42202);
  static const Color interactivePressed = Color(0xFFE42202);
  static const Color interactiveFocused = Color(0xFFE64826);
  static const Color interactiveDisabled = Color(0xFFF0B3A7);
  static const Color interactiveSelected = Color(0xFFE64826);

  // Status - Success
  static const Color success = Color(0xFF1FA64A);
  static const Color successBackground = Color(0xFFEAF7EE);
  static const Color successText = Color(0xFF167A36);
  static const Color successBorder = Color(0xFFB8E4C5);

  // Status - Error
  static const Color error = Color(0xFFE42202);
  static const Color errorBackground = Color(0xFFFDECEA);
  static const Color errorText = Color(0xFFB51D08);
  static const Color errorBorder = Color(0xFFF2B8AE);

  // Status - Warning
  static const Color warning = Color(0xFFD98A00);
  static const Color warningBackground = Color(0xFFFFF5DD);
  static const Color warningText = Color(0xFF8A5900);
  static const Color warningBorder = Color(0xFFEBCB8A);

  // Status - Info
  static const Color info = Color(0xFF3983F0);
  static const Color infoBackground = Color(0xFFEDF4FF);
  static const Color infoText = Color(0xFF225FAF);
  static const Color infoBorder = Color(0xFFB9D4FA);

  // Disabled
  static const Color disabledBackground = Color(0xFFF0F0EF);
  static const Color disabledBorder = Color(0xFFE8E9EA);
  static const Color disabledText = Color(0xFF9A9A9B);
  static const Color disabledIcon = Color(0xFF9A9A9B);

  // Focus & Selection
  static const Color focus = Color(0xFFE64826);
  static const Color selection = Color(0xFFF2DFDD);

  // Warm Neutral
  static const Color warmNeutral100 = Color(0xFFF3F0E5);
  static const Color warmNeutral200 = Color(0xFFF0EBDF);
  static const Color warmNeutral300 = Color(0xFFEDE8D8);

  // Overlays
  static const Color overlayLight = Color(0x0A030204);   // 4%
  static const Color overlay = Color(0x14030204);        // 8%
  static const Color overlayStrong = Color(0x29030204);  // 16%
  static const Color overlayDark = Color(0x80030204);    // 50% for modal barrier

  // Shadows
  static const Color shadowBase = Color(0x14030204);     // rgba(3, 2, 4, 0.08)
  static const BoxShadow shadowSmall = BoxShadow(
    color: shadowBase,
    blurRadius: 4,
    offset: Offset(0, 1),
  );
  static const BoxShadow shadowMedium = BoxShadow(
    color: shadowBase,
    blurRadius: 12,
    offset: Offset(0, 4),
  );
  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x1F030204),
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}
