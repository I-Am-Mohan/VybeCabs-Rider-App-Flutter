import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/location_item.dart';
import '../../domain/vehicle_tier.dart';
import '../../../../core/services/location_service.dart';

class BookingState {
  final LocationItem? pickup;
  final List<LocationItem> stops;
  final LocationItem? destination;
  final VehicleTier selectedVehicle;
  final List<VehicleTier> availableVehicles;

  const BookingState({
    this.pickup,
    this.stops = const [],
    this.destination,
    required this.selectedVehicle,
    this.availableVehicles = VehicleTier.defaultTiers,
  });

  BookingState copyWith({
    LocationItem? pickup,
    List<LocationItem>? stops,
    LocationItem? destination,
    VehicleTier? selectedVehicle,
    List<VehicleTier>? availableVehicles,
  }) {
    return BookingState(
      pickup: pickup ?? this.pickup,
      stops: stops ?? this.stops,
      destination: destination ?? this.destination,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      availableVehicles: availableVehicles ?? this.availableVehicles,
    );
  }

  double calculateFare(VehicleTier tier) {
    // Base tier price + ₹25 for each additional intermediate stop
    final additionalStopCharge = stops.length * 25.0;
    return tier.basePrice + additionalStopCharge;
  }
}

final bookingControllerProvider =
    StateNotifierProvider<BookingController, BookingState>((ref) {
  final userLoc = ref.watch(userLocationProvider).value;
  final controller = BookingController(
    initialPickup: userLoc,
    initialDestination: null,
  );

  // Dynamically sync pickup if user location finishes resolving after initialization
  ref.listen<AsyncValue<LocationItem?>>(userLocationProvider, (prev, next) {
    if (next.value != null) {
      controller.syncUserLocationIfEmpty(next.value!);
    }
  });

  return controller;
});

class BookingController extends StateNotifier<BookingState> {
  BookingController({
    LocationItem? initialPickup,
    LocationItem? initialDestination,
  }) : super(
          BookingState(
            pickup: initialPickup,
            destination: initialDestination,
            selectedVehicle: VehicleTier.defaultTiers.first,
          ),
        );

  void syncUserLocationIfEmpty(LocationItem location) {
    if (state.pickup == null) {
      state = state.copyWith(pickup: location);
    }
  }

  void updatePickupLocation(LocationItem location) {
    state = state.copyWith(pickup: location);
  }

  void setPickup(LocationItem location) {
    state = state.copyWith(pickup: location);
  }

  void setDestination(LocationItem location) {
    state = state.copyWith(destination: location);
  }

  void addStop(LocationItem location) {
    if (state.stops.length < 3) {
      final updated = [...state.stops, location];
      state = state.copyWith(stops: updated);
    }
  }

  void removeStop(int index) {
    if (index >= 0 && index < state.stops.length) {
      final updated = [...state.stops]..removeAt(index);
      state = state.copyWith(stops: updated);
    }
  }

  void swapPickupAndDestination() {
    if (state.pickup != null && state.destination != null) {
      final oldPickup = state.pickup!;
      final oldDest = state.destination!;
      state = state.copyWith(
        pickup: oldDest.copyWith(isCurrentLocation: false),
        destination: oldPickup,
      );
    }
  }

  void selectVehicle(VehicleTier tier) {
    state = state.copyWith(selectedVehicle: tier);
  }
}
