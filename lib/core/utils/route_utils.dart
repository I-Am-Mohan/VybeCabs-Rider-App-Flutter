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

  /// Generates smooth waypoints along a multi-stop route: start -> stop1 -> stop2 -> end
  static List<LatLng> generateMultiStopRoute(List<LatLng> points, {int stepsPerLeg = 6}) {
    if (points.length < 2) return points;
    final List<LatLng> fullRoute = [];
    for (int i = 0; i < points.length - 1; i++) {
      final leg = generateWaypoints(points[i], points[i + 1], steps: stepsPerLeg);
      if (i > 0 && leg.isNotEmpty) {
        fullRoute.addAll(leg.skip(1));
      } else {
        fullRoute.addAll(leg);
      }
    }
    return fullRoute;
  }

  /// Calculates the Great Circle distance between two coordinates in kilometers using Haversine formula
  static double calculateDistanceKm(LatLng start, LatLng end) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (end.latitude - start.latitude) * pi / 180.0;
    final double dLon = (end.longitude - start.longitude) * pi / 180.0;

    final double lat1Rad = start.latitude * pi / 180.0;
    final double lat2Rad = end.latitude * pi / 180.0;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1Rad) * cos(lat2Rad);
    final double c = 2 * atan2(sqrt(a), sqrt(1.0 - a));

    return earthRadiusKm * c;
  }

  /// Calculates the midpoint between two LatLng coordinates
  static LatLng calculateMidpoint(LatLng p1, LatLng p2) {
    return LatLng(
      (p1.latitude + p2.latitude) / 2,
      (p1.longitude + p2.longitude) / 2,
    );
  }

  /// Generates a realistic random starting position for a driver located
  /// [minDistanceKm] to [maxDistanceKm] away from the user's [pickup] coordinates (default 2.0 - 3.0 km).
  static LatLng generateNearbyDriverPosition(
    LatLng pickup, {
    double minDistanceKm = 2.0,
    double maxDistanceKm = 3.0,
    Random? random,
  }) {
    final rng = random ?? Random();

    // Area-uniform random distance within the [minDistanceKm, maxDistanceKm] circular band
    final double u = rng.nextDouble();
    final double distanceKm = sqrt(
      u * (maxDistanceKm * maxDistanceKm - minDistanceKm * minDistanceKm) +
          (minDistanceKm * minDistanceKm),
    );

    // Random bearing angle in [0, 2*pi) radians (0 to 360 degrees)
    final double bearingRad = rng.nextDouble() * 2 * pi;

    const double earthRadiusKm = 6371.0;
    final double angularDistance = distanceKm / earthRadiusKm;

    final double lat1Rad = pickup.latitude * pi / 180.0;
    final double lon1Rad = pickup.longitude * pi / 180.0;

    // Geodesic destination point calculation on sphere
    final double lat2Rad = asin(
      sin(lat1Rad) * cos(angularDistance) +
          cos(lat1Rad) * sin(angularDistance) * cos(bearingRad),
    );

    final double lon2Rad = lon1Rad +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(lat1Rad),
          cos(angularDistance) - sin(lat1Rad) * sin(lat2Rad),
        );

    final double lat2 = lat2Rad * 180.0 / pi;
    final double lon2 = ((lon2Rad * 180.0 / pi + 540.0) % 360.0) - 180.0;

    return LatLng(lat2, lon2);
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
