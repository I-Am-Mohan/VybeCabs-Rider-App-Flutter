import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../booking/domain/location_item.dart';
import '../../booking/domain/vehicle_tier.dart';
import 'driver_model.dart';

enum RideStage {
  idle,
  findingDriver,
  driverAccepted,
  driverEnRoute,
  driverArrived,
  rideStarted,
  reachedDestination,
  completed,
}

enum PaymentMethod { cash, upi, card }

enum PaymentStatus { pending, paid }

class ActiveRideState {
  final String id;
  final RideStage stage;
  final LocationItem pickup;
  final List<LocationItem> stops;
  final LocationItem destination;
  final VehicleTier vehicleTier;
  final DriverModel? driver;
  final String ridePin; // 4-digit PIN to share with driver
  final double fare;
  final LatLng driverLocation;
  final double driverBearing;
  final int etaSeconds;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime startTime;
  final List<LatLng> currentRouteWaypoints;

  const ActiveRideState({
    required this.id,
    this.stage = RideStage.idle,
    required this.pickup,
    this.stops = const [],
    required this.destination,
    required this.vehicleTier,
    this.driver,
    this.ridePin = '4821',
    required this.fare,
    required this.driverLocation,
    this.driverBearing = 0.0,
    this.etaSeconds = 180,
    this.paymentMethod = PaymentMethod.upi,
    this.paymentStatus = PaymentStatus.pending,
    required this.startTime,
    this.currentRouteWaypoints = const [],
  });

  ActiveRideState copyWith({
    String? id,
    RideStage? stage,
    LocationItem? pickup,
    List<LocationItem>? stops,
    LocationItem? destination,
    VehicleTier? vehicleTier,
    DriverModel? driver,
    String? ridePin,
    double? fare,
    LatLng? driverLocation,
    double? driverBearing,
    int? etaSeconds,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DateTime? startTime,
    List<LatLng>? currentRouteWaypoints,
  }) {
    return ActiveRideState(
      id: id ?? this.id,
      stage: stage ?? this.stage,
      pickup: pickup ?? this.pickup,
      stops: stops ?? this.stops,
      destination: destination ?? this.destination,
      vehicleTier: vehicleTier ?? this.vehicleTier,
      driver: driver ?? this.driver,
      ridePin: ridePin ?? this.ridePin,
      fare: fare ?? this.fare,
      driverLocation: driverLocation ?? this.driverLocation,
      driverBearing: driverBearing ?? this.driverBearing,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      startTime: startTime ?? this.startTime,
      currentRouteWaypoints:
          currentRouteWaypoints ?? this.currentRouteWaypoints,
    );
  }

  Map<String, dynamic> toHistoryMap() {
    return {
      'id': id,
      'date': startTime.toIso8601String(),
      'pickup': pickup.title,
      'destination': destination.title,
      'stops': stops.map((s) => s.title).toList(),
      'fare': fare,
      'vehicleType': '${vehicleTier.name} (${vehicleTier.type.name.toUpperCase()})',
      'driverName': driver?.name ?? 'Assigned Driver',
      'vehicleNumber': driver?.vehicleNumber ?? 'WB 06 H 4920',
      'paymentMethod': paymentMethod.name.toUpperCase(),
      'paymentStatus': paymentStatus.name.toUpperCase(),
      'rating': 5.0,
    };
  }
}
