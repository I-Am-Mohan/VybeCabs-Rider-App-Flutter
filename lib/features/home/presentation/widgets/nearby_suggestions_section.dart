import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location_search_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bounce.dart';
import '../../../../core/widgets/vybe_skeleton.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../booking/presentation/screens/vehicle_selection_sheet.dart';

/// Section showing dynamic nearby suggestions based on user location,
/// with shimmer skeleton loading.
class NearbySuggestionsSection extends ConsumerWidget {
  const NearbySuggestionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nearbyAsync = ref.watch(nearbySuggestionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Suggestions',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        nearbyAsync.when(
          loading: () => Column(
            children: List.generate(
              3,
              (index) => const VybeSkeletonListTile(),
            ),
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (suggestions) {
            if (suggestions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap "Where are you going?" to search or pick from map',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: suggestions.take(3).map((dest) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: VybeBounce(
                    onTap: () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .setDestination(dest);
                      VehicleSelectionSheet.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5E9F0),
                          width: 1,
                        ),
                        boxShadow: const [AppColors.shadowSmall],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest.title,
                                  style: AppTypography.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.5,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dest.subtitle,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
