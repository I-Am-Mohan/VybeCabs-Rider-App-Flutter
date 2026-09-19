import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shimmer effect wrapper that sweeps a gradient highlight across child skeleton widgets
class VybeShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const VybeShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  State<VybeShimmer> createState() => _VybeShimmerState();
}

class _VybeShimmerState extends State<VybeShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final progress = _controller.value;
            final double dx = bounds.width * (progress * 2.5 - 0.75);
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE8E8EE),
                Color(0xFFF6F6F9),
                Color(0xFFE8E8EE),
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(slidePercent: dx / bounds.width),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Primitive skeleton placeholder shapes
class VybeSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const VybeSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  factory VybeSkeleton.rectangular({
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return VybeSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      shape: BoxShape.rectangle,
    );
  }

  factory VybeSkeleton.circular({required double radius}) {
    return VybeSkeleton(
      width: radius * 2,
      height: radius * 2,
      shape: BoxShape.circle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8EE),
        borderRadius: shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(8)) : null,
        shape: shape,
      ),
    );
  }
}

/// Pre-built skeleton list tile for place/destination suggestions
class VybeSkeletonListTile extends StatelessWidget {
  const VybeSkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return VybeShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            VybeSkeleton.circular(radius: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VybeSkeleton.rectangular(width: 140, height: 14),
                  const SizedBox(height: 8),
                  VybeSkeleton.rectangular(width: double.infinity, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-built skeleton for card loading
class VybeSkeletonCard extends StatelessWidget {
  final double height;
  const VybeSkeletonCard({super.key, this.height = 140});

  @override
  Widget build(BuildContext context) {
    return VybeShimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8EE),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
