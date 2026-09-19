import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/utils/route_utils.dart';
import '../../../booking/domain/vehicle_tier.dart';
import '../../../booking/presentation/controllers/booking_controller.dart';
import '../../domain/driver_model.dart';
import '../../domain/ride_state.dart';

final trackingControllerProvider =
    StateNotifierProvider<TrackingController, ActiveRideState?>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return TrackingController(storage);
});

class TrackingController extends StateNotifier<ActiveRideState?> {
  final LocalStorageService _storage;
  Timer? _simulationTimer;
  int _currentWaypointIndex = 0;
  List<LatLng> _driverToPickupWaypoints = [];
  List<LatLng> _tripWaypoints = [];

  TrackingController(this._storage) : super(null);

  void startRideBooking(BookingState booking) {
    if (booking.pickup == null || booking.destination == null) return;
    final pickup = booking.pickup!;
    final destination = booking.destination!;

    _simulationTimer?.cancel();
    _currentWaypointIndex = 0;

    final rideId = 'ride_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final randomPin = '${1000 + Random().nextInt(9000)}';
    final fare = booking.calculateFare(booking.selectedVehicle);

    DriverModel driver;
    switch (booking.selectedVehicle.type) {
      case VehicleType.bike:
        driver = DriverModel.sampleBikeDriver;
        break;
      case VehicleType.tirri:
        driver = DriverModel.sampleTirriDriver;
        break;
      case VehicleType.car:
        driver = DriverModel.sampleCarDriver;
        break;
    }

    final pickupCoord = pickup.coordinates;
    final destCoord = destination.coordinates;
    final initialDriverLocation = RouteUtils.generateNearbyDriverPosition(pickupCoord);

    // Dynamically generate waypoints relative to real location
    _driverToPickupWaypoints = RouteUtils.generateWaypoints(
      initialDriverLocation,
      pickupCoord,
      steps: 6,
    );

    // Multi-stop route: Pickup -> Stop 1 -> Stop 2 -> Destination
    final tripPoints = [
      pickupCoord,
      ...booking.stops.map((s) => s.coordinates),
      destCoord,
    ];
    _tripWaypoints = RouteUtils.generateMultiStopRoute(tripPoints, stepsPerLeg: 6);

    state = ActiveRideState(
      id: rideId,
      stage: RideStage.findingDriver,
      pickup: pickup,
      stops: booking.stops,
      destination: destination,
      vehicleTier: booking.selectedVehicle,
      driver: driver,
      ridePin: randomPin,
      fare: fare,
      driverLocation: initialDriverLocation,
      etaSeconds: 180,
      startTime: DateTime.now(),
      currentRouteWaypoints: _driverToPickupWaypoints,
    );

    // 1. Simulate finding driver (3 seconds)
    _simulationTimer = Timer(const Duration(seconds: 3), () {
      _onDriverAccepted();
    });
  }

  void _onDriverAccepted() {
    if (state == null) return;
    state = state!.copyWith(
      stage: RideStage.driverAccepted,
      etaSeconds: 120,
    );

    // After 2.5 seconds, start driver movement toward pickup
    _simulationTimer = Timer(const Duration(milliseconds: 2500), () {
      _startDriverEnRouteSimulation();
    });
  }

  void _startDriverEnRouteSimulation() {
    if (state == null) return;
    state = state!.copyWith(stage: RideStage.driverEnRoute);
    _currentWaypointIndex = 0;

    final waypoints = _driverToPickupWaypoints;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      if (_currentWaypointIndex < waypoints.length - 1) {
        _currentWaypointIndex++;
        final nextCoord = waypoints[_currentWaypointIndex];
        final prevCoord = waypoints[_currentWaypointIndex - 1];
        final bearing = RouteUtils.calculateBearing(prevCoord, nextCoord);

        state = state!.copyWith(
          driverLocation: nextCoord,
          driverBearing: bearing,
          etaSeconds: max(0, 120 - (_currentWaypointIndex * 20)),
        );
      } else {
        // Driver reached pickup!
        timer.cancel();
        _onDriverArrived();
      }
    });
  }

  void _onDriverArrived() {
    if (state == null) return;
    state = state!.copyWith(
      stage: RideStage.driverArrived,
      driverLocation: state!.pickup.coordinates,
      etaSeconds: 0,
    );

    // After 3 seconds, trip starts
    _simulationTimer = Timer(const Duration(seconds: 3), () {
      _startTripSimulation();
    });
  }

  void _startTripSimulation() {
    if (state == null) return;
    state = state!.copyWith(
      stage: RideStage.rideStarted,
      etaSeconds: 300,
      currentRouteWaypoints: _tripWaypoints,
    );
    _currentWaypointIndex = 0;

    final waypoints = _tripWaypoints;

    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }

      if (_currentWaypointIndex < waypoints.length - 1) {
        _currentWaypointIndex++;
        final nextCoord = waypoints[_currentWaypointIndex];
        final prevCoord = waypoints[_currentWaypointIndex - 1];
        final bearing = RouteUtils.calculateBearing(prevCoord, nextCoord);

        state = state!.copyWith(
          driverLocation: nextCoord,
          driverBearing: bearing,
          etaSeconds: max(0, 300 - (_currentWaypointIndex * 35)),
        );
      } else {
        // Reached destination!
        timer.cancel();
        _onDestinationReached();
      }
    });
  }

  void _onDestinationReached() {
    if (state == null) return;
    state = state!.copyWith(
      stage: RideStage.reachedDestination,
      driverLocation: state!.destination.coordinates,
      etaSeconds: 0,
    );
  }

  Future<void> processPayment(PaymentMethod method) async {
    if (state == null) return;

    state = state!.copyWith(
      paymentMethod: method,
      paymentStatus: PaymentStatus.paid,
    );

    // Update in dynamic localstorage
    await _storage.updateRide(state!.id, {
      'paymentMethod': method.name.toUpperCase(),
      'paymentStatus': 'PAID',
    });
  }

  Future<void> finishAndSaveRide() async {
    if (state == null) return;

    // Save full ride details to persistent local storage
    final rideMap = state!.toHistoryMap();
    await _storage.saveRide(rideMap);

    state = state!.copyWith(stage: RideStage.completed);
  }

  void cancelRide() {
    _simulationTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
