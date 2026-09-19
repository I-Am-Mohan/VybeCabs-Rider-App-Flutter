import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bounce.dart';
import 'taxi_illustration.dart';

/// Featured "Quick Ride" card matching home.jpg:
/// - Light peach background with primary orange border
/// - Clock badge, title, instant badge, checkmark
/// - Rider-adapted description
/// - Side-view taxi illustration on right
class QuickRideCard extends StatelessWidget {
  final VoidCallback onTap;

  const QuickRideCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VybeBounce(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF6EE), // Warm peach background
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.primary,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Clock Icon + Title + Pill Badge + Right Checkmark
            Row(
              children: [
                // White square badge with clock
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
                      Icons.access_time_rounded,
                      size: 20,
                      color: Color(0xFFE55726),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Title
                Text(
                  'Quick Ride',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),

                // Instant mode badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE55726),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'INSTANT',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Colors.white,
                    ),
                  ),
                ),

                const Spacer(),

                // Right checkmark
                const Icon(
                  Icons.check_circle_rounded,
                  size: 24,
                  color: Color(0xFFE55726),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Content Row: Left description text + Right taxi illustration
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Book instant cabs, autos & bikes with upfront fares',
                    style: AppTypography.bodyMedium.copyWith(
                      color: const Color(0xFF5A6270),
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const TaxiIllustration(
                  width: 130,
                  height: 66,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
