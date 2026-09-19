import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_badge.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../booking/presentation/screens/location_selector_screen.dart';
import '../../../booking/data/booking_dummy_data.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../../booking/presentation/screens/vehicle_selection_sheet.dart';
import '../widgets/switch_account_sheet.dart';
import '../widgets/profile_menu_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedCategoryIndex = 0; // 0: Ride, 1: Work, 2: Care

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final user = authState.user;
    final userName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (storage.userName.isNotEmpty ? storage.userName : 'Rider');
    final userPhone = user?.phone.isNotEmpty == true
        ? user!.phone
        : (storage.userPhone.isNotEmpty ? storage.userPhone : '');

    final userLocationAsync = ref.watch(userLocationProvider);
    final userAddress =
        userLocationAsync.value?.subtitle ??
        (userLocationAsync.isLoading ? 'Locating...' : 'Current Location');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Bar matching 4.jpg
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => SwitchAccountSheet.show(
                        context,
                        name: userName,
                        phone: userPhone,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_getGreeting()} $userName',
                                style: AppTypography.titleLarge.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20,
                                color: AppColors.iconPrimary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userAddress,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => ProfileMenuSheet.show(context, name: userName),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                        color: AppColors.surface,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 24,
                        color: AppColors.iconPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Search Bar matching 4.jpg ("Where are you going?")
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LocationSelectorScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [AppColors.shadowSmall],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.iconSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Where are you going?',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Category Tabs matching 4.jpg: Ride, Work, Care
              Row(
                children: [
                  _buildCategoryTab(
                    index: 0,
                    label: 'Ride',
                    icon: Icons.directions_car_filled_outlined,
                  ),
                  const SizedBox(width: 28),
                  _buildCategoryTab(
                    index: 1,
                    label: 'Work',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(width: 28),
                  _buildCategoryTab(
                    index: 2,
                    label: 'Care',
                    icon: Icons.volunteer_activism_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Subtitle
              Text(
                'Quick rides and pre-planned rides',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // 4. Grid of Cards matching 4.jpg
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tall Left Card: Quick Ride
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LocationSelectorScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 310,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7F4), // Light peach card bg
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.primarySoft,
                            width: 1.2,
                          ),
                          boxShadow: const [AppColors.shadowSmall],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Spacer(),
                            // 3D Car Illustration container
                            Center(
                              child: Container(
                                width: 130,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [AppColors.shadowSmall],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.local_taxi_rounded,
                                    size: 56,
                                    color: Color(0xFFE59837),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.speed_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Quick Ride',
                              style: AppTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Instant ride with\navailable vehicles',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Right 2 stacked cards: Airport Pickup & Scheduled Ride
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        // Card 1: Airport Pickup
                        InkWell(
                          onTap: () {
                            ref
                                .read(bookingControllerProvider.notifier)
                                .setDestination(
                                  BookingDummyData
                                      .popularDestinations[2], // Airport
                                );
                            VehicleSelectionSheet.show(context);
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 148,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [AppColors.shadowSmall],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: VybeBadge(
                                    label: 'Coming Soon',
                                    type: VybeBadgeType.neutral,
                                  ),
                                ),
                                const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 24,
                                  color: AppColors.iconSecondary,
                                ),
                                const Spacer(),
                                Text(
                                  'Airport Pickup',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'OTP-based pickup at airport zones',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Card 2: Scheduled Ride
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LocationSelectorScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 148,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.border),
                              boxShadow: const [AppColors.shadowSmall],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Align(
                                  alignment: Alignment.topRight,
                                  child: VybeBadge(
                                    label: 'Coming Soon',
                                    type: VybeBadgeType.neutral,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 22,
                                  color: AppColors.iconSecondary,
                                ),
                                const Spacer(),
                                Text(
                                  'Scheduled Ride',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Book for later, full day or multiple days',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent / Quick destinations
              Text(
                'Popular Destinations',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              ...BookingDummyData.popularDestinations.take(3).map((dest) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(bookingControllerProvider.notifier)
                          .setDestination(dest);
                      VehicleSelectionSheet.show(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSecondary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_outlined,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dest.title,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dest.subtitle,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.iconDisabled,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.iconSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 2.5,
            width: 48,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
