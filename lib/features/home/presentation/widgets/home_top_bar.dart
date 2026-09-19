import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vybe_bounce.dart';
import 'profile_menu_sheet.dart';
import 'switch_account_sheet.dart';

/// Top app bar for the Home screen matching home.jpg:
/// - Left hamburger menu opens ProfileMenuSheet
/// - Right notification bell with indicator dot
/// - Right profile avatar circle opens SwitchAccountSheet
class HomeTopBar extends StatelessWidget {
  final String userName;
  final String userPhone;

  const HomeTopBar({
    super.key,
    required this.userName,
    required this.userPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Left Hamburger Menu
        VybeBounce(
          onTap: () => ProfileMenuSheet.show(context, name: userName),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.centerLeft,
            child: const Icon(
              Icons.menu_rounded,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // 2. Right Actions (Notification Bell + Profile Avatar)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Avatar Button
            VybeBounce(
              onTap: () => SwitchAccountSheet.show(
                context,
                name: userName,
                phone: userPhone,
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: const [AppColors.shadowSmall],
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
