import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum VybeBadgeType { brand, neutral, success, warning, error, info }

class VybeBadge extends StatelessWidget {
  final String label;
  final VybeBadgeType type;
  final IconData? icon;

  const VybeBadge({
    super.key,
    required this.label,
    this.type = VybeBadgeType.neutral,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (type) {
      case VybeBadgeType.brand:
        bgColor = AppColors.primarySoft;
        textColor = AppColors.primary;
        break;
      case VybeBadgeType.neutral:
        bgColor = AppColors.warmNeutral100.withValues(alpha: 0.8);
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.warmNeutral200, width: 0.8);
        break;
      case VybeBadgeType.success:
        bgColor = AppColors.successBackground;
        textColor = AppColors.successText;
        border = Border.all(color: AppColors.successBorder, width: 0.8);
        break;
      case VybeBadgeType.warning:
        bgColor = AppColors.warningBackground;
        textColor = AppColors.warningText;
        border = Border.all(color: AppColors.warningBorder, width: 0.8);
        break;
      case VybeBadgeType.error:
        bgColor = AppColors.errorBackground;
        textColor = AppColors.errorText;
        border = Border.all(color: AppColors.errorBorder, width: 0.8);
        break;
      case VybeBadgeType.info:
        bgColor = AppColors.infoBackground;
        textColor = AppColors.infoText;
        border = Border.all(color: AppColors.infoBorder, width: 0.8);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
