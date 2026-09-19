import 'package:flutter/material.dart';

/// Stylized side-view yellow taxi illustration matching home.jpg
class TaxiIllustration extends StatelessWidget {
  final double width;
  final double height;

  const TaxiIllustration({
    super.key,
    this.width = 135,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TaxiPainter(),
      ),
    );
  }
}

class _TaxiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ground shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.92),
        width: w * 0.85,
        height: h * 0.16,
      ),
      shadowPaint,
    );

    // Taxi Body (Yellow)
    const taxiYellow = Color(0xFFF9B828);
    const taxiYellowDark = Color(0xFFE5A015);
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [taxiYellow, taxiYellowDark],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Car silhouette path
    final carPath = Path();
    carPath.moveTo(w * 0.08, h * 0.70); // Front bumper bottom
    carPath.lineTo(w * 0.05, h * 0.60); // Front bumper curve
    carPath.lineTo(w * 0.15, h * 0.45); // Hood start
    carPath.lineTo(w * 0.32, h * 0.42); // Hood to windshield base
    carPath.lineTo(w * 0.45, h * 0.22); // Windshield slope to roof
    carPath.lineTo(w * 0.72, h * 0.22); // Roof
    carPath.lineTo(w * 0.84, h * 0.45); // Rear glass slope
    carPath.lineTo(w * 0.95, h * 0.48); // Trunk
    carPath.lineTo(w * 0.98, h * 0.62); // Rear bumper curve
    carPath.lineTo(w * 0.92, h * 0.70); // Rear bumper bottom
    // Rear wheel arch
    carPath.arcToPoint(
      Offset(w * 0.70, h * 0.70),
      radius: Radius.circular(w * 0.12),
      clockwise: false,
    );
    // Underbody
    carPath.lineTo(w * 0.40, h * 0.70);
    // Front wheel arch
    carPath.arcToPoint(
      Offset(w * 0.18, h * 0.70),
      radius: Radius.circular(w * 0.12),
      clockwise: false,
    );
    carPath.close();

    canvas.drawPath(carPath, bodyPaint);

    // Roof Taxi Sign
    final signPaint = Paint()..color = Colors.white;
    final signRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.58, h * 0.16),
        width: w * 0.18,
        height: h * 0.11,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(signRect, signPaint);

    final signOrange = Paint()..color = const Color(0xFFF95A2C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * 0.58, h * 0.16),
          width: w * 0.12,
          height: h * 0.06,
        ),
        const Radius.circular(2),
      ),
      signOrange,
    );

    // Blue tinted windows
    final windowPaint = Paint()..color = const Color(0xFF2C6FB7);

    // Front window
    final frontWin = Path();
    frontWin.moveTo(w * 0.35, h * 0.42);
    frontWin.lineTo(w * 0.46, h * 0.25);
    frontWin.lineTo(w * 0.56, h * 0.25);
    frontWin.lineTo(w * 0.56, h * 0.42);
    frontWin.close();
    canvas.drawPath(frontWin, windowPaint);

    // Rear window
    final rearWin = Path();
    rearWin.moveTo(w * 0.59, h * 0.25);
    rearWin.lineTo(w * 0.70, h * 0.25);
    rearWin.lineTo(w * 0.81, h * 0.42);
    rearWin.lineTo(w * 0.59, h * 0.42);
    rearWin.close();
    canvas.drawPath(rearWin, windowPaint);

    // Window highlight line
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.37, h * 0.41), Offset(w * 0.46, h * 0.27), hlPaint);

    // Headlight (Cyan / White)
    final lightPaint = Paint()..color = const Color(0xFFE2F4FF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.04, h * 0.50, w * 0.06, h * 0.10),
        const Radius.circular(2),
      ),
      lightPaint,
    );

    // Taillight (Red)
    final redPaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.94, h * 0.51, w * 0.04, h * 0.10),
        const Radius.circular(2),
      ),
      redPaint,
    );

    // Door line
    final doorPaint = Paint()
      ..color = const Color(0xFFD68A05)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.575, h * 0.25), Offset(w * 0.575, h * 0.69), doorPaint);

    // Wheels
    _drawWheel(canvas, Offset(w * 0.29, h * 0.70), w * 0.11);
    _drawWheel(canvas, Offset(w * 0.81, h * 0.70), w * 0.11);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius) {
    // Outer tire (Dark)
    final tirePaint = Paint()..color = const Color(0xFF22262E);
    canvas.drawCircle(center, radius, tirePaint);

    // Inner rim (Silver/Gray)
    final rimPaint = Paint()..color = const Color(0xFFBAC2CF);
    canvas.drawCircle(center, radius * 0.56, rimPaint);

    // Hub center (Dark)
    final hubPaint = Paint()..color = const Color(0xFF474E5D);
    canvas.drawCircle(center, radius * 0.25, hubPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
