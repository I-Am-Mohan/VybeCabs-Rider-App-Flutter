import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../features/booking/domain/location_item.dart';
import 'location_service.dart';

final locationSearchServiceProvider = Provider<LocationSearchService>((ref) {
  return LocationSearchService();
});

class LocationSearchService {
  final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 6);

  /// Real-time search for places, streets, landmarks, and addresses
  Future<List<LocationItem>> search(
    String query, {
    LatLng? proximity,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // 1. Try real OpenStreetMap / Nominatim geocoding
    try {
      final results = await _searchNominatim(trimmed, proximity: proximity);
      if (results.isNotEmpty) {
        return results;
      }
    } catch (_) {
      // Fall through to native geocoder
    }

    // 2. Fallback to native device Geocoder
    try {
      final nativeResults = await _searchNative(trimmed);
      if (nativeResults.isNotEmpty) {
        return nativeResults;
      }
    } catch (_) {}

    return [];
  }

  Future<List<LocationItem>> _searchNominatim(
    String query, {
    LatLng? proximity,
  }) async {
    final params = <String, String>{
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': '10',
    };

    if (proximity != null) {
      // Prioritize area within ~50km of rider
      final minLat = proximity.latitude - 0.5;
      final maxLat = proximity.latitude + 0.5;
      final minLon = proximity.longitude - 0.5;
      final maxLon = proximity.longitude + 0.5;
      params['viewbox'] = '$minLon,$maxLat,$maxLon,$minLat';
      params['bounded'] = '0'; // Prioritize vicinity

      if (proximity.latitude >= 6.0 &&
          proximity.latitude <= 38.0 &&
          proximity.longitude >= 68.0 &&
          proximity.longitude <= 98.0) {
        params['countrycodes'] = 'in';
      }
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);
    final request = await _httpClient.getUrl(uri);
    request.headers.set('User-Agent', 'VybeCabsRider/1.0 (Android; Flutter)');
    request.headers.set('Accept', 'application/json');

    final response = await request.close();
    if (response.statusCode != 200) return [];

    final responseBody = await response.transform(utf8.decoder).join();
    final data = json.decode(responseBody) as List<dynamic>;

    final items = <LocationItem>[];
    for (int i = 0; i < data.length; i++) {
      final item = data[i] as Map<String, dynamic>;
      final lat = double.tryParse(item['lat']?.toString() ?? '');
      final lon = double.tryParse(item['lon']?.toString() ?? '');
      if (lat == null || lon == null) continue;

      final displayName = item['display_name'] as String? ?? '';
      final parts = displayName.split(',').map((s) => s.trim()).toList();

      final title = (item['name'] as String?)?.isNotEmpty == true
          ? (item['name'] as String)
          : (parts.isNotEmpty ? parts.first : 'Location Result');

      final subtitle = parts.length > 1
          ? parts.sublist(1).take(3).join(', ')
          : displayName;

      items.add(
        LocationItem(
          id: 'real_search_${item['place_id'] ?? i}',
          title: title,
          subtitle: subtitle,
          coordinates: LatLng(lat, lon),
        ),
      );
    }

    if (proximity != null && items.isNotEmpty) {
      items.sort((a, b) {
        final distA = _calculateDistance(a.coordinates, proximity);
        final distB = _calculateDistance(b.coordinates, proximity);
        return distA.compareTo(distB);
      });
    }

    return items;
  }

  static double _calculateDistance(LatLng a, LatLng b) {
    const p = 0.017453292519943295;
    final c = cos;
    final val = 0.5 -
        c((b.latitude - a.latitude) * p) / 2 +
        c(a.latitude * p) *
            c(b.latitude * p) *
            (1 - c((b.longitude - a.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(val));
  }

  Future<List<LocationItem>> _searchNative(String query) async {
    final geocoding = Geocoding();
    final locations = await geocoding.locationFromAddress(query);
    final items = <LocationItem>[];

    for (int i = 0; i < locations.length && i < 5; i++) {
      final loc = locations[i];
      String subtitle = '${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          subtitle = [
            p.subLocality,
            p.locality,
            p.administrativeArea,
          ].where((s) => s != null && s.isNotEmpty).join(', ');
        }
      } catch (_) {}

      items.add(
        LocationItem(
          id: 'native_search_$i',
          title: query,
          subtitle: subtitle.isNotEmpty ? subtitle : 'Real Address',
          coordinates: LatLng(loc.latitude, loc.longitude),
        ),
      );
    }

    return items;
  }

  /// Fetches real nearby places (stations, hospitals, malls) around user coordinates
  Future<List<LocationItem>> getNearbySuggestions(LatLng userLocation) async {
    final categories = ['station', 'hospital', 'mall'];
    final List<LocationItem> combined = [];
    final seenTitles = <String>{};

    for (final cat in categories) {
      try {
        final results = await _searchNominatim(cat, proximity: userLocation);
        for (final item in results) {
          final key = item.title.trim().toLowerCase();
          if (key.isNotEmpty &&
              key != 'location result' &&
              !seenTitles.contains(key)) {
            seenTitles.add(key);
            combined.add(item);
          }
        }
      } catch (_) {}
      if (combined.length >= 6) break;
    }

    if (combined.isNotEmpty) {
      combined.sort((a, b) {
        final dA = _calculateDistance(a.coordinates, userLocation);
        final dB = _calculateDistance(b.coordinates, userLocation);
        return dA.compareTo(dB);
      });
      return combined.take(6).toList();
    }

    // Fallback: reverse-geocode user location to get locality, then search native
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        userLocation.latitude,
        userLocation.longitude,
      );
      if (placemarks.isNotEmpty) {
        final locality = placemarks.first.locality ??
            placemarks.first.subLocality ??
            '';
        if (locality.isNotEmpty) {
          final results = await search(locality, proximity: userLocation);
          if (results.isNotEmpty) return results.take(5).toList();
        }
      }
    } catch (_) {}

    return [];
  }

  /// Reverse geocodes a map coordinate to a real LocationItem
  Future<LocationItem> reverseGeocode(LatLng coordinates) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final title = (p.street != null && p.street!.isNotEmpty)
            ? p.street!
            : (p.name != null && p.name!.isNotEmpty
                ? p.name!
                : (p.subLocality != null && p.subLocality!.isNotEmpty
                    ? p.subLocality!
                    : 'Pinned Location'));
        final subtitleParts = [
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
        ].where((s) => s != null && s.isNotEmpty && s != title).toList();
        final subtitle = subtitleParts.isNotEmpty
            ? subtitleParts.join(', ')
            : '${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}';

        return LocationItem(
          id: 'map_pick_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          subtitle: subtitle,
          coordinates: coordinates,
        );
      }
    } catch (_) {}

    // Fallback to OSM Nominatim reverse geocode
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': coordinates.latitude.toString(),
        'lon': coordinates.longitude.toString(),
        'format': 'json',
      });
      final request = await _httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'VybeCabsRider/1.0 (Android; Flutter)');
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final jsonMap = json.decode(body) as Map<String, dynamic>;
        final displayName = jsonMap['display_name'] as String? ?? '';
        final parts = displayName.split(',').map((s) => s.trim()).toList();
        final title = parts.isNotEmpty ? parts.first : 'Pinned Location';
        final subtitle = parts.length > 1
            ? parts.sublist(1).take(3).join(', ')
            : displayName;
        return LocationItem(
          id: 'map_pick_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          subtitle: subtitle,
          coordinates: coordinates,
        );
      }
    } catch (_) {}

    return LocationItem(
      id: 'map_pick_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Pinned Location',
      subtitle:
          '${coordinates.latitude.toStringAsFixed(5)}, ${coordinates.longitude.toStringAsFixed(5)}',
      coordinates: coordinates,
    );
  }
}

/// Dynamic nearby suggestions provider based on user's current GPS location
final nearbySuggestionsProvider =
    FutureProvider<List<LocationItem>>((ref) async {
  final userLocation = ref.watch(userLocationProvider).value;
  if (userLocation == null) return [];
  final searchService = ref.watch(locationSearchServiceProvider);
  return searchService.getNearbySuggestions(userLocation.coordinates);
});
