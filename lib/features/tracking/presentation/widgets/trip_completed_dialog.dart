import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../../domain/ride_state.dart';
import '../controllers/tracking_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../home/presentation/screens/home_screen.dart';

class TripCompletedDialog extends ConsumerStatefulWidget {
  final ActiveRideState ride;

  const TripCompletedDialog({super.key, required this.ride});

  static Future<void> show(BuildContext context, {required ActiveRideState ride}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => TripCompletedDialog(ride: ride),
    );
  }

  @override
  ConsumerState<TripCompletedDialog> createState() => _TripCompletedDialogState();
}

class _TripCompletedDialogState extends ConsumerState<TripCompletedDialog> {
  int _selectedRating = 5;

  void _onDone() async {
    // Save to local storage and update history provider
    await ref.read(trackingControllerProvider.notifier).finishAndSaveRide();
    ref.read(rideHistoryProvider.notifier).loadHistory();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;

    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.successBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 40,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Trip Completed!',
              style: AppTypography.headlineLarge.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hope you had a comfortable ride with Vybe',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),

            // Ride details summary card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Fare Paid',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '₹${ride.fare.toStringAsFixed(0)}',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 20),
                  Row(
                    children: [
                      const Icon(Icons.trip_origin, size: 14, color: AppColors.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.pickup.title,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ride.destination.title,
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rating Stars
            Text(
              'Rate your driver (${ride.driver?.name ?? 'Driver'})',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNum = index + 1;
                return IconButton(
                  icon: Icon(
                    starNum <= _selectedRating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFE59837),
                    size: 28,
                  ),
                  onPressed: () => setState(() => _selectedRating = starNum),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Done Button
            VybeButton(
              label: 'Back to Home',
              onPressed: _onDone,
            ),
          ],
        ),
      ),
    );
  }
}
