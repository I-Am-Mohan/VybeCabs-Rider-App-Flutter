import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bottom_sheet.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../controllers/booking_controller.dart';
import '../../../tracking/presentation/controllers/tracking_controller.dart';
import '../../../tracking/presentation/screens/live_tracking_screen.dart';

class VehicleSelectionSheet extends ConsumerWidget {
  const VehicleSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    return VybeBottomSheet.show(
      context: context,
      builder: (ctx) => const VehicleSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingControllerProvider);
    final bookingNotifier = ref.read(bookingControllerProvider.notifier);

    return VybeBottomSheet(
      title: 'Choose Your Ride',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stops summary badge if intermediate stops exist
          if (booking.stops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warmNeutral100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warmNeutral200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.alt_route, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Includes ${booking.stops.length} stop${booking.stops.length > 1 ? 's' : ''}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Available Car / Bike / Tirri Options
          ...booking.availableVehicles.map((tier) {
            final isSelected = booking.selectedVehicle.id == tier.id;
            final fare = booking.calculateFare(tier);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => bookingNotifier.selectVehicle(tier),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primarySoft.withValues(alpha: 0.35)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.8 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x1AE64826),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ]
                        : const [AppColors.shadowSmall],
                  ),
                  child: Row(
                    children: [
                      // Vehicle Icon Badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surface
                              : AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          tier.icon,
                          size: 28,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.iconPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Vehicle details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  tier.name,
                                  style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.person,
                                  size: 14,
                                  color: AppColors.iconSecondary,
                                ),
                                Text(
                                  '${tier.capacity}',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${tier.etaMinutes} mins away • ${tier.description}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${fare.toStringAsFixed(0)}',
                            style: AppTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Fare',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Payment option row preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Payment: UPI / Cash / Card',
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Flexible',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.successText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Book Ride Button
          VybeButton(
            label:
                'Book ${booking.selectedVehicle.name} • ₹${booking.calculateFare(booking.selectedVehicle).toStringAsFixed(0)}',
            onPressed: () {
              Navigator.of(context).pop(); // Close bottom sheet
              // Start tracking simulation
              ref
                  .read(trackingControllerProvider.notifier)
                  .startRideBooking(booking);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LiveTrackingScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
