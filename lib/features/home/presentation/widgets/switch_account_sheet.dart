import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_bottom_sheet.dart';

class SwitchAccountSheet extends StatelessWidget {
  final String userName;
  final String userPhone;

  const SwitchAccountSheet({
    super.key,
    required this.userName,
    required this.userPhone,
  });

  static Future<void> show(BuildContext context, {required String name, required String phone}) {
    return VybeBottomSheet.show(
      context: context,
      builder: (ctx) => SwitchAccountSheet(userName: name, userPhone: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VybeBottomSheet(
      title: 'Switch account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // Active Personal Account
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.warmNeutral100,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userPhone,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.primaryOnColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderSubtle, height: 24),
          // Link another account
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account linking feature coming soon'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.add, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Link another account',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Footer notice
          Center(
            child: Text(
              'Switching context doesn\'t sign you out — your\npersonal account stays saved.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
