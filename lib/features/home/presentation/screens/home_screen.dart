import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/widgets/vybe_bounce.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../booking/presentation/screens/location_selector_screen.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/home_greeting_section.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/quick_ride_card.dart';
import '../widgets/office_commute_card.dart';
import '../widgets/service_grid_card.dart';
import '../widgets/nearby_suggestions_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final user = authState.user;
    final userName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (storage.userName.isNotEmpty ? storage.userName : 'Rider');
    final userPhone = user?.phone.isNotEmpty == true
        ? user!.phone
        : (storage.userPhone.isNotEmpty ? storage.userPhone : '');

    void navigateToBooking() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const LocationSelectorScreen(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar matching home.jpg
              // Hamburger menu (left) -> ProfileMenuSheet
              // Bell (right) & Profile avatar (right) -> SwitchAccountSheet
              VybeFadeSlide(
                duration: const Duration(milliseconds: 300),
                child: HomeTopBar(
                  userName: userName,
                  userPhone: userPhone,
                ),
              ),
              const SizedBox(height: 18),

              // 2. Greeting & Name across 2 distinct lines + Subtitle
              VybeFadeSlide(
                duration: const Duration(milliseconds: 350),
                delay: const Duration(milliseconds: 50),
                child: HomeGreetingSection(userName: userName),
              ),
              const SizedBox(height: 18),

              // 3. Search Bar ("Where are you going?")
              VybeFadeSlide(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 100),
                child: HomeSearchBar(onTap: navigateToBooking),
              ),
              const SizedBox(height: 20),

              // 4. Featured Card 1: Quick Ride (matching home.jpg)
              VybeFadeSlide(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 150),
                child: QuickRideCard(onTap: navigateToBooking),
              ),
              const SizedBox(height: 14),

              // 5. Featured Card 2: Office Commute (matching home.jpg)
              VybeFadeSlide(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 200),
                child: OfficeCommuteCard(onTap: navigateToBooking),
              ),
              const SizedBox(height: 14),

              // 6. Split Cards: Airport Pickups & Scheduled Trips (matching home.jpg)
              VybeFadeSlide(
                duration: const Duration(milliseconds: 550),
                delay: const Duration(milliseconds: 250),
                child: Row(
                  children: [
                    ServiceGridCard(
                      icon: Icons.flight_takeoff_rounded,
                      title: 'Airport Pickups',
                      description: 'Terminal pickup & drop with flight tracking',
                      onTap: navigateToBooking,
                    ),
                    const SizedBox(width: 14),
                    ServiceGridCard(
                      icon: Icons.calendar_today_rounded,
                      title: 'Scheduled Trips',
                      description: 'Book in advance for worry-free travel',
                      onTap: navigateToBooking,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // 7. Dynamic Nearby Suggestions Section with Skeleton Loaders
              const VybeFadeSlide(
                duration: Duration(milliseconds: 600),
                delay: Duration(milliseconds: 300),
                child: NearbySuggestionsSection(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
