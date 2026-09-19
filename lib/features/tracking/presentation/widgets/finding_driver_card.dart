import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_animated_pulse.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../../domain/ride_state.dart';

class FindingDriverCard extends StatelessWidget {
  final ActiveRideState ride;
  final VoidCallback onCancel;

  const FindingDriverCard({
    super.key,
    required this.ride,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [AppColors.shadowLarge],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            VybeAnimatedPulse(
              size: 100,
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x40E64826),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Icon(
                  ride.vehicleTier.icon,
                  color: AppColors.primaryOnColor,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Waiting for drivers to accept your request',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Connecting with nearby ${ride.vehicleTier.name} drivers...',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(ride.vehicleTier.icon,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        ride.vehicleTier.name,
                        style: AppTypography.titleMedium
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Text(
                    '₹${ride.fare.toStringAsFixed(0)}',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            VybeButton(
              label: 'Cancel Request',
              variant: VybeButtonVariant.secondary,
              height: 48,
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}
