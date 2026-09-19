import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract final class RouteUtils {
  /// Dynamically generates smooth waypoints between start and end coordinates
  static List<LatLng> generateWaypoints(LatLng start, LatLng end, {int steps = 7}) {
    final List<LatLng> waypoints = [];
    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      // Introduce slight curved street offsets for realistic road geometry
      final double curve = sin(t * pi) * 0.0012;
      final double lat = start.latitude + (end.latitude - start.latitude) * t + curve;
      final double lng = start.longitude + (end.longitude - start.longitude) * t - (curve * 0.4);
      waypoints.add(LatLng(lat, lng));
    }
    return waypoints;
  }

  /// Generates a realistic starting point for a driver ~700-900m away from pickup
  static LatLng generateNearbyDriverPosition(LatLng pickup) {
    return LatLng(
      pickup.latitude + 0.0058,
      pickup.longitude + 0.0042,
    );
  }

  /// Calculates the vehicle bearing / heading between two LatLng coordinates in degrees
  static double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180;
    final double lng1 = start.longitude * pi / 180;
    final double lat2 = end.latitude * pi / 180;
    final double lng2 = end.longitude * pi / 180;

    final double dLng = lng2 - lng1;
    final double y = sin(dLng) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    final double radians = atan2(y, x);
    return (radians * 180 / pi + 360) % 360;
  }
}
