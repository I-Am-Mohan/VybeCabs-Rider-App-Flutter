import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../../data/booking_dummy_data.dart';
import '../../domain/location_item.dart';
import '../controllers/booking_controller.dart';
import 'vehicle_selection_sheet.dart';

class LocationSelectorScreen extends ConsumerStatefulWidget {
  const LocationSelectorScreen({super.key});

  @override
  ConsumerState<LocationSelectorScreen> createState() =>
      _LocationSelectorScreenState();
}

class _LocationSelectorScreenState
    extends ConsumerState<LocationSelectorScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  List<LocationItem> _filteredDestinations = [];

  @override
  void initState() {
    super.initState();
    _filteredDestinations = BookingDummyData.popularDestinations;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    final pickup = ref.read(bookingControllerProvider).pickup;
    final allDestinations =
        BookingDummyData.getDestinationsNear(pickup.coordinates);
    setState(() {
      if (query.isEmpty) {
        _filteredDestinations = allDestinations;
      } else {
        _filteredDestinations = allDestinations
            .where((d) =>
                d.title.toLowerCase().contains(query) ||
                d.subtitle.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _showAddStopDialog() {
    final booking = ref.read(bookingControllerProvider);
    final availableStops =
        BookingDummyData.getDestinationsNear(booking.pickup.coordinates);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add Intermediate Stop',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableStops.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.borderSubtle),
                    itemBuilder: (context, index) {
                      final item = availableStops[index];
                      return ListTile(
                        leading: const Icon(Icons.add_location_alt_outlined,
                            color: AppColors.primary),
                        title: Text(item.title,
                            style: AppTypography.titleMedium
                                .copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(item.subtitle,
                            style: AppTypography.bodySmall),
                        onTap: () {
                          ref
                              .read(bookingControllerProvider.notifier)
                              .addStop(item);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingControllerProvider);
    final bookingNotifier = ref.read(bookingControllerProvider.notifier);

    // Prepare Map Markers
    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('pickup'),
        position: booking.pickup.coordinates,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: 'Pickup: ${booking.pickup.title}'),
      ),
      if (booking.destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: booking.destination!.coordinates,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Drop: ${booking.destination!.title}'),
        ),
      ...booking.stops.asMap().entries.map(
            (entry) => Marker(
              markerId: MarkerId('stop_${entry.key}'),
              position: entry.value.coordinates,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueYellow),
              infoWindow: InfoWindow(
                  title: 'Stop ${entry.key + 1}: ${entry.value.title}'),
            ),
          ),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Plan Your Route'),
      ),
      body: Column(
        children: [
          // 1. Google Map View with live markers
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: booking.pickup.coordinates,
                    zoom: 13,
                  ),
                  markers: markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map',
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.iconPrimary,
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          booking.pickup.coordinates,
                          14,
                        ),
                      );
                    },
                    child: const Icon(Icons.my_location, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 2. Route Builder: Pickup, Stops, Destination
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [AppColors.shadowSmall],
                    ),
                    child: Column(
                      children: [
                        // Pickup row
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    booking.pickup.title,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.swap_vert_rounded,
                                  color: AppColors.iconSecondary),
                              onPressed: () =>
                                  bookingNotifier.swapPickupAndDestination(),
                            ),
                          ],
                        ),

                        // Multiple intermediate stops
                        if (booking.stops.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...booking.stops.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final stop = entry.value;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.warning,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Stop ${idx + 1}',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.warning,
                                          ),
                                        ),
                                        Text(
                                          stop.title,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: AppColors.iconMuted,
                                    ),
                                    onPressed: () =>
                                        bookingNotifier.removeStop(idx),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const Divider(color: AppColors.borderSubtle, height: 20),

                        // Destination row
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Drop-off',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    booking.destination?.title ??
                                        'Select destination',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: booking.destination != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Button to Add Stop
                            if (booking.stops.length < 3)
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                ),
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Stop',
                                    style: TextStyle(fontSize: 12)),
                                onPressed: _showAddStopDialog,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search input for destinations
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search landmark or street...',
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.iconSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Select Destination',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Destination Suggestions List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredDestinations.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: AppColors.borderSubtle),
                    itemBuilder: (context, index) {
                      final item = _filteredDestinations[index];
                      final isSelected = booking.destination?.id == item.id;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primarySoft
                                : AppColors.surfaceSecondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.place_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.iconSecondary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 20)
                            : null,
                        onTap: () {
                          bookingNotifier.setDestination(item);
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                                item.coordinates, 13),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // 3. Bottom Action: View Ride Options
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [AppColors.shadowMedium],
            ),
            child: SafeArea(
              child: VybeButton(
                label: 'View Ride Options',
                onPressed: booking.destination == null
                    ? null
                    : () {
                        VehicleSelectionSheet.show(context);
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
