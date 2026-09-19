import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Greeting & subtitle section displaying greeting and name across 2 distinct lines
class HomeGreetingSection extends StatelessWidget {
  final String userName;

  const HomeGreetingSection({
    super.key,
    required this.userName,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  String _getFirstName() {
    final trimmed = userName.trim();
    if (trimmed.isEmpty) return 'Rider';
    return trimmed.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2-line greeting & name
        Text(
          '${_getGreeting()}\n${_getFirstName()}',
          style: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a service to get started',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
