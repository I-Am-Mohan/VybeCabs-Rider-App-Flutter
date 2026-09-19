import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vybecabs_rider/core/services/local_storage_service.dart';
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

    test('Initial ride history seeds 6 rides', () {
      final rides = storageService.getRideHistory();
      expect(rides.length, 6);
      expect(rides.first['pickup'], isNotEmpty);
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
      expect(updatedRides.length, 7);
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
    test('Calculates fare with additional stops', () {
      final controller = BookingController();
      final baseCarFare = controller.state.calculateFare(VehicleTier.defaultTiers.first);
      expect(baseCarFare, 185.0);

      // Add intermediate stop
      controller.addStop(controller.state.pickup);
      final updatedFare = controller.state.calculateFare(VehicleTier.defaultTiers.first);
      expect(updatedFare, 210.0); // 185 + 25
    });

    test('Vehicle selection switches active tier', () {
      final controller = BookingController();
      final bikeTier = VehicleTier.defaultTiers.firstWhere((t) => t.type == VehicleType.bike);
      controller.selectVehicle(bikeTier);
      expect(controller.state.selectedVehicle.type, VehicleType.bike);
    });
  });

  group('TrackingController Tests', () {
    late LocalStorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await LocalStorageService.init();
    });

    test('Starts ride booking in findingDriver stage', () {
      final bookingController = BookingController();
      final trackingController = TrackingController(storageService);

      trackingController.startRideBooking(bookingController.state);
      expect(trackingController.state, isNotNull);
      expect(trackingController.state!.stage, RideStage.findingDriver);
      expect(trackingController.state!.ridePin.length, 4);

      trackingController.dispose();
    });

    test('Processing payment sets status to PAID and updates method', () async {
      final bookingController = BookingController();
      final trackingController = TrackingController(storageService);

      trackingController.startRideBooking(bookingController.state);
      await trackingController.processPayment(PaymentMethod.upi);

      expect(trackingController.state!.paymentStatus, PaymentStatus.paid);
      expect(trackingController.state!.paymentMethod, PaymentMethod.upi);

      trackingController.dispose();
    });
  });
}
