import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/map_marker_utils.dart';
import '../../../booking/domain/vehicle_tier.dart';
import '../../domain/ride_state.dart';
import '../controllers/tracking_controller.dart';
import '../widgets/finding_driver_card.dart';
import '../widgets/driver_info_card.dart';
import '../widgets/payment_bottom_sheet.dart';
import '../widgets/trip_completed_dialog.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  GoogleMapController? _mapController;
  bool _hasShownCompletedDialog = false;

  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _destinationIcon;
  final Map<int, BitmapDescriptor> _stopIcons = {};
  BitmapDescriptor? _vehicleIcon;
  VehicleType? _loadedVehicleType;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcons();
  }

  Future<void> _loadMarkerIcons() async {
    final pickup = await MapMarkerUtils.createIconMarker(
      icon: Icons.person_pin_circle_rounded,
      backgroundColor: const Color(0xFF00A86B), // Emerald green
      iconColor: Colors.white,
      size: 50,
    );
    final drop = await MapMarkerUtils.createIconMarker(
      icon: Icons.flag_rounded,
      backgroundColor: AppColors.primary,
      iconColor: Colors.white,
      size: 50,
    );
    final stop1 = await MapMarkerUtils.createIconMarker(
      icon: Icons.location_on_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
      stopNumber: '1',
      size: 50,
    );
    final stop2 = await MapMarkerUtils.createIconMarker(
      icon: Icons.location_on_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
      stopNumber: '2',
      size: 50,
    );
    final stop3 = await MapMarkerUtils.createIconMarker(
      icon: Icons.location_on_rounded,
      backgroundColor: const Color(0xFFF59E0B),
      iconColor: Colors.white,
      stopNumber: '3',
      size: 50,
    );
    if (mounted) {
      setState(() {
        _pickupIcon = pickup;
        _destinationIcon = drop;
        _stopIcons[0] = stop1;
        _stopIcons[1] = stop2;
        _stopIcons[2] = stop3;
      });
    }
  }

  Future<void> _ensureVehicleIcon(VehicleType type) async {
    if (_vehicleIcon != null && _loadedVehicleType == type) return;
    final icon = await MapMarkerUtils.createVehicleMarker(vehicleType: type);
    if (mounted) {
      setState(() {
        _vehicleIcon = icon;
        _loadedVehicleType = type;
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _listenRideState(ActiveRideState? previous, ActiveRideState? next) {
    if (next == null) return;

    // Camera animation following the driver
    if (previous?.driverLocation != next.driverLocation) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: next.driverLocation,
            zoom: 15.5,
            bearing: next.driverBearing,
          ),
        ),
      );
    }

    // Destination reached transition
    if (next.stage == RideStage.reachedDestination &&
        !_hasShownCompletedDialog) {
      _hasShownCompletedDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (next.paymentStatus == PaymentStatus.pending) {
          // If still not paid, show payment sheet first, then completion dialog
          PaymentBottomSheet.show(context, ride: next).then((_) {
            if (mounted) {
              final updated = ref.read(trackingControllerProvider);
              if (updated != null) {
                TripCompletedDialog.show(context, ride: updated);
              }
            }
          });
        } else {
          // Already paid, directly show completion dialog
          TripCompletedDialog.show(context, ride: next);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ActiveRideState?>(
      trackingControllerProvider,
      (previous, next) => _listenRideState(previous, next),
    );

    final ride = ref.watch(trackingControllerProvider);

    if (ride == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Ride Status')),
        body: const Center(child: Text('No active ride found.')),
      );
    }

    // Build Polylines
    final polylinePoints = ride.currentRouteWaypoints.isNotEmpty
        ? ride.currentRouteWaypoints
        : [ride.pickup.coordinates, ride.destination.coordinates];

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('active_route'),
        points: polylinePoints,
        color: AppColors.primary,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    _ensureVehicleIcon(ride.vehicleTier.type);

    // Build Markers with custom icons
    final Set<Marker> markers = {
      // Pickup Marker
      Marker(
        markerId: const MarkerId('pickup_pin'),
        position: ride.pickup.coordinates,
        icon:
            _pickupIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'Pickup: ${ride.pickup.title}'),
      ),
      // Destination Marker
      Marker(
        markerId: const MarkerId('destination_pin'),
        position: ride.destination.coordinates,
        icon:
            _destinationIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: 'Drop: ${ride.destination.title}'),
      ),
      // Stops Markers
      ...ride.stops.asMap().entries.map(
        (entry) => Marker(
          markerId: MarkerId('stop_marker_${entry.key}'),
          position: entry.value.coordinates,
          icon:
              _stopIcons[entry.key] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: 'Stop ${entry.key + 1}: ${entry.value.title}',
          ),
        ),
      ),
      // Driver Marker
      if (ride.stage != RideStage.findingDriver)
        Marker(
          markerId: const MarkerId('driver_marker'),
          position: ride.driverLocation,
          rotation: ride.driverBearing,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          icon:
              _vehicleIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: ride.driver?.name ?? 'Driver',
            snippet: '${ride.vehicleTier.name} • ${ride.driver?.vehicleNumber}',
          ),
        ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Google Maps View
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: ride.pickup.coordinates,
              zoom: 14.5,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // 2. Top Header Overlay (Back / Cancel / Trip Status)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (ride.stage == RideStage.findingDriver) {
                          ref
                              .read(trackingControllerProvider.notifier)
                              .cancelRide();
                        }
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: const [AppColors.shadowMedium],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: AppColors.iconPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppColors.shadowSmall],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ride.stage == RideStage.findingDriver
                                ? 'Finding Driver...'
                                : (ride.stage == RideStage.rideStarted
                                      ? 'Ride In Progress'
                                      : (ride.stage == RideStage.driverArrived
                                            ? 'Driver Arrived'
                                            : 'Driver Assigned')),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Recenter button
                    FloatingActionButton.small(
                      heroTag: 'tracking_recenter',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.iconPrimary,
                      elevation: 2,
                      onPressed: () {
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngZoom(ride.driverLocation, 15.5),
                        );
                      },
                      child: const Icon(Icons.my_location, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Dynamic Bottom Cards matching the active stage
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ride.stage == RideStage.findingDriver
                  ? FindingDriverCard(
                      key: const ValueKey('finding_card'),
                      ride: ride,
                      onCancel: () {
                        ref
                            .read(trackingControllerProvider.notifier)
                            .cancelRide();
                        Navigator.of(context).pop();
                      },
                    )
                  : DriverInfoCard(
                      key: const ValueKey('driver_info_card'),
                      ride: ride,
                      onOpenPayment: () {
                        PaymentBottomSheet.show(context, ride: ride);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
