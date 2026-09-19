import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_badge.dart';
import '../../../../core/widgets/vybe_bottom_sheet.dart';
import '../controllers/history_controller.dart';

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rides = ref.watch(rideHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Your Trips'),
      ),
      body: rides.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_car_outlined,
                      size: 36,
                      color: AppColors.iconDisabled,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No trips taken yet',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your completed rides will be saved here dynamically.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: rides.length,
              separatorBuilder: (context, index) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final ride = rides[index];
                final dateStr = ride['date'] as String?;
                DateTime? date;
                if (dateStr != null) {
                  date = DateTime.tryParse(dateStr);
                }
                final formattedDate = date != null
                    ? DateFormat('EEE, dd MMM yyyy • hh:mm a').format(date)
                    : 'Recent Trip';

                final fare = (ride['fare'] as num?)?.toDouble() ?? 0.0;
                final vehicleType = ride['vehicleType'] as String? ?? 'Vybe Go';
                final pickup = ride['pickup'] as String? ?? '';
                final destination = ride['destination'] as String? ?? '';
                final driverName = ride['driverName'] as String? ?? 'Driver';
                final vehicleNumber = ride['vehicleNumber'] as String? ?? '';
                final paymentMethod = ride['paymentMethod'] as String? ?? 'UPI';

                IconData vehicleIcon = Icons.directions_car_rounded;
                if (vehicleType.toLowerCase().contains('bike') ||
                    vehicleType.toLowerCase().contains('moto')) {
                  vehicleIcon = Icons.two_wheeler_rounded;
                } else if (vehicleType.toLowerCase().contains('tirri') ||
                    vehicleType.toLowerCase().contains('rickshaw')) {
                  vehicleIcon = Icons.electric_rickshaw_rounded;
                }

                return InkWell(
                  onTap: () => _showTripDetails(context, ride),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [AppColors.shadowSmall],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Vehicle icon, Name, Fare
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                vehicleIcon,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicleType,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    formattedDate,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '₹${fare.toStringAsFixed(0)}',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.borderSubtle, height: 24),

                        // Route: Pickup & Destination
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.trip_origin,
                                    size: 12, color: AppColors.info),
                                Container(
                                  width: 1.5,
                                  height: 22,
                                  color: AppColors.borderStrong,
                                ),
                                const Icon(Icons.location_on,
                                    size: 14, color: AppColors.primary),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pickup,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    destination,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Footer: Driver & Payment info
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$driverName ($vehicleNumber)',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentMethod,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const VybeBadge(
                              label: 'COMPLETED',
                              type: VybeBadgeType.success,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showTripDetails(BuildContext context, Map<String, dynamic> ride) {
    VybeBottomSheet.show(
      context: context,
      builder: (ctx) {
        final fare = (ride['fare'] as num?)?.toDouble() ?? 0.0;
        final stops = (ride['stops'] as List<dynamic>?) ?? [];

        return VybeBottomSheet(
          title: 'Trip Receipt',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fare Paid',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${fare.toStringAsFixed(0)}',
                      style: AppTypography.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Ride ID', ride['id'] ?? 'N/A'),
              _buildDetailRow('Vehicle', ride['vehicleType'] ?? 'Vybe Go'),
              _buildDetailRow('Driver', '${ride['driverName']} (${ride['vehicleNumber']})'),
              _buildDetailRow('Pickup', ride['pickup'] ?? ''),
              if (stops.isNotEmpty)
                _buildDetailRow('Intermediate Stops', stops.join(', ')),
              _buildDetailRow('Destination', ride['destination'] ?? ''),
              _buildDetailRow('Payment Method', ride['paymentMethod'] ?? 'UPI'),
              _buildDetailRow('Status', ride['paymentStatus'] ?? 'PAID'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
