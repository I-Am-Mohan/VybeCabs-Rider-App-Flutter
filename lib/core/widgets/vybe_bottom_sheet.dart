import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class VybeBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final bool showCloseButton;
  final EdgeInsetsGeometry contentPadding;

  const VybeBottomSheet({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.showCloseButton = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            const SizedBox(height: 12),
            // Grab handle
            Center(
              child: Container(
                width: 48,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (title != null || showCloseButton) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                    ?trailing,
                    if (showCloseButton) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 22,
                            color: AppColors.iconSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: 16),
            ],
            Padding(
              padding: contentPadding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
