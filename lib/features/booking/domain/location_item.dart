import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationItem {
  final String id;
  final String title;
  final String subtitle;
  final LatLng coordinates;
  final bool isCurrentLocation;

  const LocationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.coordinates,
    this.isCurrentLocation = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'isCurrentLocation': isCurrentLocation,
    };
  }

  factory LocationItem.fromMap(Map<String, dynamic> map) {
    return LocationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      coordinates: LatLng(
        (map['latitude'] as num?)?.toDouble() ?? 0.0,
        (map['longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      isCurrentLocation: map['isCurrentLocation'] ?? false,
    );
  }

  LocationItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    LatLng? coordinates,
    bool? isCurrentLocation,
  }) {
    return LocationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      coordinates: coordinates ?? this.coordinates,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
    );
  }
}
