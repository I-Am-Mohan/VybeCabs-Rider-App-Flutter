import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/location_item.dart';

abstract final class BookingDummyData {
  static LatLng? lastKnownLocation;

  static void setLastKnownLocation(LatLng loc) {
    lastKnownLocation = loc;
  }

  static List<LocationItem> get popularDestinations {
    final center = lastKnownLocation ?? const LatLng(28.6139, 77.2090);
    return getDestinationsNear(center);
  }

  static LocationItem getInitialPickup(LatLng? coords, String? address) {
    if (coords != null) {
      return LocationItem(
        id: 'real_current_pickup',
        title: address != null && address.contains(',')
            ? address.split(',').first.trim()
            : (address ?? 'Current Location'),
        subtitle: address ?? 'Your Current GPS Position',
        coordinates: coords,
        isCurrentLocation: true,
      );
    }
    return const LocationItem(
      id: 'default_pickup',
      title: 'Current Location',
      subtitle: 'Locating via GPS...',
      coordinates: LatLng(28.6139, 77.2090),
      isCurrentLocation: true,
    );
  }

  static List<LocationItem> getDestinationsNear(LatLng userLocation) {
    return [
      LocationItem(
        id: 'dest_city_center',
        title: 'City Center Mall',
        subtitle: 'Commercial & Shopping Complex',
        coordinates: LatLng(
          userLocation.latitude + 0.018,
          userLocation.longitude + 0.015,
        ),
      ),
      LocationItem(
        id: 'dest_airport',
        title: 'International Airport',
        subtitle: 'Terminal 1 & 2 Departure Gates',
        coordinates: LatLng(
          userLocation.latitude + 0.045,
          userLocation.longitude + 0.035,
        ),
      ),
      LocationItem(
        id: 'dest_tech_park',
        title: 'Tech Park IT Hub',
        subtitle: 'Gate 2, Business District',
        coordinates: LatLng(
          userLocation.latitude + 0.028,
          userLocation.longitude - 0.020,
        ),
      ),
      LocationItem(
        id: 'dest_railway_station',
        title: 'Central Railway Station',
        subtitle: 'Main Concourse & Taxi Stand',
        coordinates: LatLng(
          userLocation.latitude - 0.032,
          userLocation.longitude - 0.018,
        ),
      ),
      LocationItem(
        id: 'dest_lake_promenade',
        title: 'Botanical Gardens & Lake',
        subtitle: 'Promenade & Walking Area',
        coordinates: LatLng(
          userLocation.latitude - 0.015,
          userLocation.longitude + 0.012,
        ),
      ),
    ];
  }
}
