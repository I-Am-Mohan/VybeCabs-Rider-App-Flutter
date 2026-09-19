import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/booking/domain/vehicle_tier.dart';
import '../theme/app_colors.dart';

abstract final class MapMarkerUtils {
  static final Map<String, BitmapDescriptor> _cache = {};

  /// Creates a modern, high-DPI icon badge marker for Google Maps
  static Future<BitmapDescriptor> createIconMarker({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    String? stopNumber,
    double size = 85,
  }) async {
    final cacheKey =
        'icon_${icon.codePoint}_${backgroundColor.toARGB32()}_${iconColor.toARGB32()}_${stopNumber}_$size';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final width = size;
    final height = size * 1.18;

    // 1. Drop shadow at base
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(width / 2, size / 2 + 3), size / 2 - 8, shadowPaint);

    // 2. White outer border
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width / 2, size / 2), size / 2 - 6, whitePaint);

    // 3. Inner colored disc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width / 2, size / 2), size / 2 - 11, bgPaint);

    // 4. Pointer arrow at the bottom of the pin
    final pointerPath = Path()
      ..moveTo(width / 2 - 8, size - 13)
      ..lineTo(width / 2 + 8, size - 13)
      ..lineTo(width / 2, height - 2)
      ..close();
    canvas.drawPath(pointerPath, whitePaint);

    final innerPointerPath = Path()
      ..moveTo(width / 2 - 5, size - 15)
      ..lineTo(width / 2 + 5, size - 15)
      ..lineTo(width / 2, height - 5)
      ..close();
    canvas.drawPath(innerPointerPath, bgPaint);

    // 5. Draw the Material Icon glyph in the center
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.44,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: iconColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        (size / 2 - textPainter.height / 2) - 2,
      ),
    );

    // 6. Stop number badge if intermediate stop (e.g. "1", "2")
    if (stopNumber != null) {
      final badgeCenter = Offset(width - 14, 16);
      canvas.drawCircle(
        badgeCenter,
        12,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
      canvas.drawCircle(badgeCenter, 12, Paint()..color = Colors.white);
      canvas.drawCircle(badgeCenter, 9.5, Paint()..color = backgroundColor);

      final numPainter = TextPainter(
        text: TextSpan(
          text: stopNumber,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      numPainter.layout();
      numPainter.paint(
        canvas,
        Offset(
          badgeCenter.dx - numPainter.width / 2,
          badgeCenter.dy - numPainter.height / 2,
        ),
      );
    }

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());

    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  /// Creates a compact, sleek vehicle marker with forward heading indicator
  static Future<BitmapDescriptor> createVehicleMarker({
    required VehicleType vehicleType,
    double size = 64,
  }) async {
    final cacheKey = 'vehicle_${vehicleType.name}_$size';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final width = size;
    final height = size;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(
        Offset(width / 2, height / 2 + 2), size / 2 - 8, shadowPaint);

    // Dark sleek circular disc
    final discPaint = Paint()
      ..color = const Color(0xFF181C24)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width / 2, height / 2), size / 2 - 7, discPaint);

    // Accent ring (Vybe Primary Orange)
    final ringPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;
    canvas.drawCircle(Offset(width / 2, height / 2), size / 2 - 7, ringPaint);

    // Direction arrow at 12 o'clock
    final arrowPath = Path()
      ..moveTo(width / 2, 2)
      ..lineTo(width / 2 - 6, 11)
      ..lineTo(width / 2 + 6, 11)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = AppColors.primary);

    // Vehicle Icon
    IconData icon;
    switch (vehicleType) {
      case VehicleType.car:
        icon = Icons.directions_car_rounded;
        break;
      case VehicleType.bike:
        icon = Icons.two_wheeler_rounded;
        break;
      case VehicleType.tirri:
        icon = Icons.electric_rickshaw_rounded;
        break;
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.44,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        (height - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(byteData!.buffer.asUint8List());

    _cache[cacheKey] = descriptor;
    return descriptor;
  }
}
