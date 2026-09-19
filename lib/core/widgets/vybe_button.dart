import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum VybeButtonVariant { primary, secondary, text, destructive }

class VybeButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final VybeButtonVariant variant;
  final double height;
  final double borderRadius;

  const VybeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.variant = VybeButtonVariant.primary,
    this.height = 54,
    this.borderRadius = 14,
  });

  @override
  State<VybeButton> createState() => _VybeButtonState();
}

class _VybeButtonState extends State<VybeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null || widget.isLoading) {
      if (widget.variant == VybeButtonVariant.primary) {
        return AppColors.primaryDisabled;
      }
      return AppColors.disabledBackground;
    }
    switch (widget.variant) {
      case VybeButtonVariant.primary:
        return AppColors.primary;
      case VybeButtonVariant.secondary:
        return AppColors.surface;
      case VybeButtonVariant.text:
        return Colors.transparent;
      case VybeButtonVariant.destructive:
        return AppColors.error;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null || widget.isLoading) {
      if (widget.variant == VybeButtonVariant.primary) {
        return AppColors.textOnPrimary;
      }
      return AppColors.disabledText;
    }
    switch (widget.variant) {
      case VybeButtonVariant.primary:
      case VybeButtonVariant.destructive:
        return AppColors.textOnPrimary;
      case VybeButtonVariant.secondary:
        return AppColors.textPrimary;
      case VybeButtonVariant.text:
        return AppColors.primary;
    }
  }

  Border? _getBorder() {
    if (widget.variant == VybeButtonVariant.secondary) {
      return Border.all(
        color: widget.onPressed == null
            ? AppColors.disabledBorder
            : AppColors.borderStrong,
        width: 1.2,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final border = _getBorder();

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: textColor),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: AppTypography.labelLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: widget.onPressed != null && !widget.isLoading
              ? (_) => _animController.forward()
              : null,
          onTapUp: widget.onPressed != null && !widget.isLoading
              ? (_) => _animController.reverse()
              : null,
          onTapCancel: () => _animController.reverse(),
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: widget.height,
            width: widget.isFullWidth ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: border,
              boxShadow: (widget.variant == VybeButtonVariant.primary &&
                      widget.onPressed != null &&
                      !widget.isLoading)
                  ? const [
                      BoxShadow(
                        color: Color(0x33E64826),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
