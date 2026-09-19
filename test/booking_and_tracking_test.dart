import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vybecabs_rider/core/services/local_storage_service.dart';
import 'package:vybecabs_rider/core/utils/route_utils.dart';
import 'package:vybecabs_rider/features/booking/domain/location_item.dart';
import 'package:vybecabs_rider/features/booking/domain/vehicle_tier.dart';
import 'package:vybecabs_rider/features/booking/presentation/controllers/booking_controller.dart';
import 'package:vybecabs_rider/features/tracking/domain/ride_state.dart';
import 'package:vybecabs_rider/features/tracking/presentation/controllers/tracking_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService Tests', () {
    late LocalStorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await LocalStorageService.init();
    });

    test('Initial ride history starts empty', () {
      final rides = storageService.getRideHistory();
      expect(rides.isEmpty, true);
    });

    test('Saving new ride dynamically persists at top of history', () async {
      final newRide = {
        'id': 'test_ride_999',
        'date': DateTime.now().toIso8601String(),
        'pickup': 'Test Pickup',
        'destination': 'Test Drop',
        'fare': 150.0,
        'vehicleType': 'Vybe Go',
        'paymentStatus': 'PAID',
      };

      await storageService.saveRide(newRide);
      final updatedRides = storageService.getRideHistory();
      expect(updatedRides.length, 1);
      expect(updatedRides.first['id'], 'test_ride_999');
    });

    test('User profile getters and setters work correctly', () async {
      expect(storageService.isLoggedIn, false);
      await storageService.setLoggedIn(true);
      await storageService.setUserName('Mohan Biswas');
      await storageService.setUserPhone('+91 6289761298');

      expect(storageService.isLoggedIn, true);
      expect(storageService.userName, 'Mohan Biswas');
      expect(storageService.userPhone, '+91 6289761298');
    });
  });

  group('BookingController Tests', () {
    final testPickup = LocationItem(
      id: 'pickup_1',
      title: 'My Location',
      subtitle: 'Current GPS Location',
      coordinates: const LatLng(22.5021, 88.3581),
      isCurrentLocation: true,
    );
    final testDrop = LocationItem(
      id: 'dest_1',
      title: 'Drop Location',
      subtitle: 'Selected Destination',
      coordinates: const LatLng(22.5100, 88.3600),
    );

    test('Calculates fare with additional stops', () {
      final controller = BookingController(
        initialPickup: testPickup,
        initialDestination: testDrop,
      );
      final baseCarFare = controller.state.calculateFare(VehicleTier.defaultTiers.first);
      expect(baseCarFare, 185.0);

      // Add intermediate stop
      controller.addStop(testPickup);
      final updatedFare = controller.state.calculateFare(VehicleTier.defaultTiers.first);
      expect(updatedFare, 210.0); // 185 + 25
    });

    test('Vehicle selection switches active tier', () {
      final controller = BookingController(
        initialPickup: testPickup,
        initialDestination: testDrop,
      );
      final bikeTier = VehicleTier.defaultTiers.firstWhere((t) => t.type == VehicleType.bike);
      controller.selectVehicle(bikeTier);
      expect(controller.state.selectedVehicle.type, VehicleType.bike);
    });
  });

  group('TrackingController Tests', () {
    late LocalStorageService storageService;
    final testPickup = LocationItem(
      id: 'pickup_1',
      title: 'Pickup Point',
      subtitle: 'Current Location',
      coordinates: const LatLng(22.5021, 88.3581),
      isCurrentLocation: true,
    );
    final testDrop = LocationItem(
      id: 'dest_1',
      title: 'Destination Point',
      subtitle: 'Destination Area',
      coordinates: const LatLng(22.5100, 88.3600),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await LocalStorageService.init();
    });

    test('Starts ride booking in findingDriver stage', () {
      final bookingController = BookingController(
        initialPickup: testPickup,
        initialDestination: testDrop,
      );
      final trackingController = TrackingController(storageService);

      trackingController.startRideBooking(bookingController.state);
      expect(trackingController.state, isNotNull);
      expect(trackingController.state!.stage, RideStage.findingDriver);
      expect(trackingController.state!.ridePin.length, 4);

      trackingController.dispose();
    });

    test('Processing payment sets status to PAID and updates method', () async {
      final bookingController = BookingController(
        initialPickup: testPickup,
        initialDestination: testDrop,
      );
      final trackingController = TrackingController(storageService);

      trackingController.startRideBooking(bookingController.state);
      await trackingController.processPayment(PaymentMethod.upi);

      expect(trackingController.state!.paymentStatus, PaymentStatus.paid);
      expect(trackingController.state!.paymentMethod, PaymentMethod.upi);

      trackingController.dispose();
    });
  });

  group('RouteUtils Multi-Stop Tests', () {
    test('generateMultiStopRoute visits pickup, stops, and drop-off', () {
      final pickup = const LatLng(22.7231, 88.4812);
      final stop1 = const LatLng(22.7280, 88.4890);
      final stop2 = const LatLng(22.7310, 88.4920);
      final drop = const LatLng(22.7400, 88.5000);

      final route = RouteUtils.generateMultiStopRoute([pickup, stop1, stop2, drop], stepsPerLeg: 4);

      // Route should have waypoints for 3 legs (4 * 3 + 1 = 13 points)
      expect(route.length, 13);
      expect(route.first.latitude, closeTo(pickup.latitude, 0.001));
      expect(route.last.latitude, closeTo(drop.latitude, 0.001));
    });

    test('calculateBearing returns valid heading angle', () {
      final start = const LatLng(22.0, 88.0);
      final north = const LatLng(23.0, 88.0);
      final bearing = RouteUtils.calculateBearing(start, north);
      expect(bearing, closeTo(0.0, 1.0)); // Heading north is ~0 degrees
    });
  });
}
