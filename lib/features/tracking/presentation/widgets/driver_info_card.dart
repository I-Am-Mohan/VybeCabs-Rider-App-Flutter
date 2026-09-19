import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_badge.dart';
import '../../domain/ride_state.dart';

class DriverInfoCard extends StatelessWidget {
  final ActiveRideState ride;
  final VoidCallback onOpenPayment;

  const DriverInfoCard({
    super.key,
    required this.ride,
    required this.onOpenPayment,
  });

  @override
  Widget build(BuildContext context) {
    final driver = ride.driver;
    final isArrived = ride.stage == RideStage.driverArrived;
    final isStarted = ride.stage == RideStage.rideStarted;
    final isReached = ride.stage == RideStage.reachedDestination;

    String statusTitle;
    VybeBadgeType badgeType;
    if (isReached) {
      statusTitle = 'Reached Destination';
      badgeType = VybeBadgeType.success;
    } else if (isStarted) {
      statusTitle = 'Trip in Progress';
      badgeType = VybeBadgeType.info;
    } else if (isArrived) {
      statusTitle = 'Driver has arrived!';
      badgeType = VybeBadgeType.warning;
    } else {
      statusTitle = 'Driver is on the way';
      badgeType = VybeBadgeType.brand;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [AppColors.shadowLarge],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grab handle
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
            const SizedBox(height: 14),

            // Top Status Bar
            Row(
              children: [
                VybeBadge(label: statusTitle, type: badgeType),
                const Spacer(),
                if (!isReached && !isArrived) ...[
                  const Icon(Icons.access_time_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${(ride.etaSeconds / 60).ceil()} min${(ride.etaSeconds / 60).ceil() > 1 ? 's' : ''}',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Driver & Vehicle Profile
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driver Avatar
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.warmNeutral100,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 30, color: AppColors.iconSecondary),
                  ),
                ),
                const SizedBox(width: 14),
                // Driver Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              driver?.name ?? 'Assigned Driver',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.star, size: 16, color: Color(0xFFE59837)),
                          Text(
                            ' ${driver?.rating ?? 4.9}',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${driver?.vehicleModel ?? ride.vehicleTier.name} • ${driver?.vehicleNumber ?? 'WB 06 H 4920'}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Call / Message quick icons
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling driver ${driver?.name}...'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Icon(Icons.call_rounded,
                            size: 18, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat with driver opened'),
                            backgroundColor: AppColors.info,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded,
                            size: 18, color: AppColors.iconSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: AppColors.borderSubtle, height: 24),

            // User's 4-digit Ride PIN (Prompt requirement: "show my pin which I need to share with the driver")
            if (!isStarted && !isReached) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primarySoft),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'START PIN',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Share with driver at pickup',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // 4 PIN Boxes
                    Row(
                      children: ride.ridePin.split('').map((char) {
                        return Container(
                          margin: const EdgeInsets.only(left: 6),
                          width: 32,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 1.2),
                          ),
                          child: Center(
                            child: Text(
                              char,
                              style: const TextStyle(
                                fontFamily: AppTypography.fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Payment bar at bottom during transit / before arrival
            // User requested: "then simluate going to destinations at bootom show payment options as before ride complete user can pay"
            InkWell(
              onTap: onOpenPayment,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ride.paymentStatus == PaymentStatus.paid
                      ? AppColors.successBackground
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ride.paymentStatus == PaymentStatus.paid
                        ? AppColors.successBorder
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      ride.paymentStatus == PaymentStatus.paid
                          ? Icons.check_circle_rounded
                          : Icons.account_balance_wallet_outlined,
                      color: ride.paymentStatus == PaymentStatus.paid
                          ? AppColors.success
                          : AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.paymentStatus == PaymentStatus.paid
                                ? 'Paid via ${ride.paymentMethod.name.toUpperCase()}'
                                : 'Pay ₹${ride.fare.toStringAsFixed(0)} (Flexible)',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: ride.paymentStatus == PaymentStatus.paid
                                  ? AppColors.successText
                                  : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ride.paymentStatus == PaymentStatus.paid
                                ? 'Receipt will be saved in your trips'
                                : 'Pay now before or after ride completion',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ride.paymentStatus == PaymentStatus.pending)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            color: AppColors.primaryOnColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.check,
                        color: AppColors.success,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
