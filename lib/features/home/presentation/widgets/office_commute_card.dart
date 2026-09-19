import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bounce.dart';
import 'buildings_illustration.dart';

/// "Office Commute" card matching home.jpg:
/// - Light grayish-blue background
/// - Briefcase badge, title, chevron arrow
/// - Rider-adapted description
/// - 3D isometric buildings illustration on right
class OfficeCommuteCard extends StatelessWidget {
  final VoidCallback onTap;

  const OfficeCommuteCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VybeBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6FA), // Light soft blue bg
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFDFE9F2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Briefcase Badge + Title
            Row(
              children: [
                // White square badge with briefcase
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.work_outline_rounded,
                      size: 20,
                      color: Color(0xFF2B5B84),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title
                Text(
                  'Office Commute',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content Row: Left description text + Right 3D Buildings illustration + Chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Daily scheduled rides to your workplace with verified drivers',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF5A6270),
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const BuildingsIllustration(
                  width: 95,
                  height: 65,
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: Color(0xFF8896A6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
