import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/booking/domain/location_item.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Riverpod provider for real dynamic user location
final userLocationProvider = FutureProvider<LocationItem?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  final coords = await locationService.getCurrentLocation();

  if (coords != null) {
    final address = await locationService.getAddressFromCoordinates(
      coords.latitude,
      coords.longitude,
    );

    return LocationItem(
      id: 'user_real_location',
      title: address.contains(',') ? address.split(',').first.trim() : address,
      subtitle: address,
      coordinates: coords,
      isCurrentLocation: true,
    );
  }

  return null;
});

class LocationService {
  Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location service is disabled
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return LatLng(lastKnown.latitude, lastKnown.longitude);
        }
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        return LatLng(lastKnown.latitude, lastKnown.longitude);
      }
      return null;
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if (p.street != null && p.street!.isNotEmpty) {
          parts.add(p.street!);
        } else if (p.name != null && p.name!.isNotEmpty) {
          parts.add(p.name!);
        }

        if (p.subLocality != null &&
            p.subLocality!.isNotEmpty &&
            !parts.contains(p.subLocality)) {
          parts.add(p.subLocality!);
        }

        if (p.locality != null &&
            p.locality!.isNotEmpty &&
            !parts.contains(p.locality)) {
          parts.add(p.locality!);
        }

        if (p.administrativeArea != null &&
            p.administrativeArea!.isNotEmpty &&
            !parts.contains(p.administrativeArea)) {
          parts.add(p.administrativeArea!);
        }

        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }
}
