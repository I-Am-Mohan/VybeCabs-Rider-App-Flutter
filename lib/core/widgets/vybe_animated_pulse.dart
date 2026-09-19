import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VybeAnimatedPulse extends StatefulWidget {
  final double size;
  final Widget child;
  final Color pulseColor;

  const VybeAnimatedPulse({
    super.key,
    this.size = 120,
    required this.child,
    this.pulseColor = AppColors.primary,
  });

  @override
  State<VybeAnimatedPulse> createState() => _VybeAnimatedPulseState();
}

class _VybeAnimatedPulseState extends State<VybeAnimatedPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Ripple 1
              _buildRipple(_controller.value, 1.0),
              // Ripple 2 (staggered)
              _buildRipple((_controller.value + 0.33) % 1.0, 0.8),
              // Ripple 3 (staggered)
              _buildRipple((_controller.value + 0.66) % 1.0, 0.6),
              // Center widget
              widget.child,
            ],
          );
        },
      ),
    );
  }

  Widget _buildRipple(double progress, double maxOpacity) {
    final scale = 0.5 + (progress * 0.5);
    final opacity = (1.0 - progress) * 0.4 * maxOpacity;

    return Transform.scale(
      scale: scale * (widget.size / 60),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.pulseColor.withValues(alpha: opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}
