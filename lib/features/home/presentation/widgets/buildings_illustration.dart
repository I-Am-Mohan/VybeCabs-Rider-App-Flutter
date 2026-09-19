import 'package:flutter/material.dart';

/// 3D isometric office buildings illustration matching home.jpg
class BuildingsIllustration extends StatelessWidget {
  final double width;
  final double height;

  const BuildingsIllustration({
    super.key,
    this.width = 110,
    this.height = 75,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _BuildingsPainter(),
      ),
    );
  }
}

class _BuildingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = const Color(0xFFD6E2EC)
      ..style = PaintingStyle.fill;
    final shadowPath = Path();
    shadowPath.moveTo(w * 0.10, h * 0.72);
    shadowPath.lineTo(w * 0.60, h * 0.96);
    shadowPath.lineTo(w * 0.95, h * 0.78);
    shadowPath.lineTo(w * 0.45, h * 0.54);
    shadowPath.close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Left building (Gray-blue)
    // Left face
    final b1LeftPaint = Paint()..color = const Color(0xFF90A4AE);
    final b1Left = Path();
    b1Left.moveTo(w * 0.18, h * 0.60);
    b1Left.lineTo(w * 0.38, h * 0.70);
    b1Left.lineTo(w * 0.38, h * 0.88);
    b1Left.lineTo(w * 0.18, h * 0.78);
    b1Left.close();
    canvas.drawPath(b1Left, b1LeftPaint);

    // Top face of left building
    final b1TopPaint = Paint()..color = const Color(0xFFCFD8DC);
    final b1Top = Path();
    b1Top.moveTo(w * 0.18, h * 0.60);
    b1Top.lineTo(w * 0.32, h * 0.53);
    b1Top.lineTo(w * 0.52, h * 0.63);
    b1Top.lineTo(w * 0.38, h * 0.70);
    b1Top.close();
    canvas.drawPath(b1Top, b1TopPaint);

    // Windows on left building
    final winPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 2; c++) {
        final cx = w * 0.23 + c * (w * 0.06);
        final cy = h * 0.67 + r * (h * 0.05) + c * (h * 0.03);
        canvas.drawCircle(Offset(cx, cy), 1.8, winPaint);
      }
    }

    // Tall Right building (Bright Blue)
    // Front-Left face
    final b2LeftPaint = Paint()..color = const Color(0xFF388AF6);
    final b2Left = Path();
    b2Left.moveTo(w * 0.42, h * 0.26);
    b2Left.lineTo(w * 0.62, h * 0.36);
    b2Left.lineTo(w * 0.62, h * 0.76);
    b2Left.lineTo(w * 0.42, h * 0.66);
    b2Left.close();
    canvas.drawPath(b2Left, b2LeftPaint);

    // Front-Right face
    final b2RightPaint = Paint()..color = const Color(0xFF5CA3FF);
    final b2Right = Path();
    b2Right.moveTo(w * 0.62, h * 0.36);
    b2Right.lineTo(w * 0.82, h * 0.26);
    b2Right.lineTo(w * 0.82, h * 0.66);
    b2Right.lineTo(w * 0.62, h * 0.76);
    b2Right.close();
    canvas.drawPath(b2Right, b2RightPaint);

    // Top face of tall building
    final b2TopPaint = Paint()..color = const Color(0xFF86BCFF);
    final b2Top = Path();
    b2Top.moveTo(w * 0.42, h * 0.26);
    b2Top.lineTo(w * 0.62, h * 0.16);
    b2Top.lineTo(w * 0.82, h * 0.26);
    b2Top.lineTo(w * 0.62, h * 0.36);
    b2Top.close();
    canvas.drawPath(b2Top, b2TopPaint);

    // Grid of windows on tall building
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 3; c++) {
        final cx = w * 0.46 + c * (w * 0.05);
        final cy = h * 0.34 + r * (h * 0.065) + c * (h * 0.025);
        canvas.drawCircle(Offset(cx, cy), 1.6, winPaint);
      }
    }

    // Right face windows
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 2; c++) {
        final cx = w * 0.67 + c * (w * 0.06);
        final cy = h * 0.41 + r * (h * 0.065) - c * (h * 0.03);
        canvas.drawCircle(Offset(cx, cy), 1.6, winPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
