import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bottom_sheet.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/get_started_screen.dart';
import '../../../history/presentation/screens/ride_history_screen.dart';

class ProfileMenuSheet extends ConsumerWidget {
  final String userName;

  const ProfileMenuSheet({super.key, required this.userName});

  static Future<void> show(BuildContext context, {required String name}) {
    return VybeBottomSheet.show(
      context: context,
      builder: (ctx) => ProfileMenuSheet(userName: name),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VybeBottomSheet(
      showCloseButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Profile Header Row
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'View profile',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: AppColors.iconSecondary,
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 24),
          // Menu Items
          _buildMenuItem(
            icon: Icons.history,
            title: 'Your Trips',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RideHistoryScreen()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.bookmark_border_rounded,
            title: 'Saved Places',
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved Places: Home & Work configured'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.local_offer_outlined,
            title: 'Offers',
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('50% off code VYBE50 applied!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Safety',
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vybe Safety: 24x7 Emergency Assistance is active'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Support',
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Customer Care: support@vybecabs.com'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'About',
            onTap: () {
              Navigator.of(context).pop();
              showAboutDialog(
                context: context,
                applicationName: 'Vybe Cabs Rider',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Vybe Technologies India',
              );
            },
          ),
          const Divider(color: AppColors.borderSubtle, height: 24),
          // Logout Option
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Log out',
            isDestructive: true,
            onTap: () async {
              Navigator.of(context).pop();
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const GetStartedScreen()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isDestructive ? AppColors.error : AppColors.iconSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDestructive ? AppColors.error : AppColors.iconSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
