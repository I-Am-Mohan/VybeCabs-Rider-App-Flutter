import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/services/location_search_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/map_marker_utils.dart';
import '../../../../core/widgets/vybe_button.dart';
import '../../domain/location_item.dart';
import '../controllers/booking_controller.dart';
import '../widgets/add_stop_bottom_sheet.dart';
import '../widgets/drop_location_picker_sheet.dart';
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
  Timer? _debounceTimer;
  bool _isSearching = false;
  bool _isMapExpanded = false;
  bool _isReverseGeocoding = false;

  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _destinationIcon;
  final Map<int, BitmapDescriptor> _stopIcons = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMarkerIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbySuggestions();
    });
  }

  Future<void> _loadNearbySuggestions() async {
    final pickup = ref.read(bookingControllerProvider).pickup;
    if (pickup != null) {
      final nearby = await ref
          .read(locationSearchServiceProvider)
          .getNearbySuggestions(pickup.coordinates);
      if (mounted && _searchController.text.trim().isEmpty) {
        setState(() {
          _filteredDestinations = nearby;
        });
      }
    }
  }

  Future<void> _loadMarkerIcons() async {
    final pickup = await MapMarkerUtils.createIconMarker(
      icon: Icons.person_pin_circle_rounded,
      backgroundColor: const Color(0xFF00A86B), // Emerald
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    _debounceTimer?.cancel();

    final pickup = ref.read(bookingControllerProvider).pickup;
    if (query.isEmpty) {
      setState(() => _isSearching = false);
      _loadNearbySuggestions();
      return;
    }

    // Real-time geocoding search
    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 380), () async {
      try {
        final realResults = await ref
            .read(locationSearchServiceProvider)
            .search(query, proximity: pickup?.coordinates);
        if (mounted) {
          setState(() {
            _isSearching = false;
            _filteredDestinations = realResults;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _handleMapTap(LatLng coordinates) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final reverseItem = await ref
          .read(locationSearchServiceProvider)
          .reverseGeocode(coordinates);
      ref.read(bookingControllerProvider.notifier).setDestination(reverseItem);
      _mapController?.animateCamera(CameraUpdate.newLatLng(coordinates));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📍 Destination set: ${reverseItem.title}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  void _showAddStopDialog() {
    final booking = ref.read(bookingControllerProvider);
    if (booking.pickup == null) return;
    AddStopBottomSheet.show(
      context,
      pickupCoordinates: booking.pickup!.coordinates,
      onStopSelected: (stop) {
        ref.read(bookingControllerProvider.notifier).addStop(stop);
        _mapController?.animateCamera(CameraUpdate.newLatLng(stop.coordinates));
      },
    );
  }

  void _openDropLocationPicker() {
    DropLocationPickerSheet.show(
      context,
      onPickOnMapRequested: () {
        setState(() => _isMapExpanded = true);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '📍 Tap anywhere on the map above to pin your destination',
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onDestinationSelected: (location) {
        ref.read(bookingControllerProvider.notifier).setDestination(location);
        _searchController.text = location.title;
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(location.coordinates, 15),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingControllerProvider);
    final bookingNotifier = ref.read(bookingControllerProvider.notifier);

    // Prepare Map Markers with custom icons
    final Set<Marker> markers = {
      if (booking.pickup != null)
        Marker(
          markerId: const MarkerId('pickup'),
          position: booking.pickup!.coordinates,
          icon:
              _pickupIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: 'Pickup: ${booking.pickup!.title}'),
        ),
      if (booking.destination != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: booking.destination!.coordinates,
          icon:
              _destinationIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(title: 'Drop: ${booking.destination!.title}'),
        ),
      ...booking.stops.asMap().entries.map(
        (entry) => Marker(
          markerId: MarkerId('stop_${entry.key}'),
          position: entry.value.coordinates,
          icon:
              _stopIcons[entry.key] ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
          infoWindow: InfoWindow(
            title: 'Stop ${entry.key + 1}: ${entry.value.title}',
          ),
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            // 1. Interactive Google Map View with pick-on-map support
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: _isMapExpanded ? 380 : 220,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          booking.pickup?.coordinates ??
                          const LatLng(22.5726, 88.3639),
                      zoom: 13,
                    ),
                    markers: markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onTap: _handleMapTap,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),

                  // Floating helper banner: "Tap map to set drop-off"
                  Positioned(
                    top: 10,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [AppColors.shadowSmall],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isReverseGeocoding)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          else
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          const SizedBox(width: 4),
                          Text(
                            _isReverseGeocoding
                                ? 'Pinning destination...'
                                : 'Tap map to set destination',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map expand/collapse button
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'toggle_map_size',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.iconPrimary,
                      onPressed: () {
                        setState(() => _isMapExpanded = !_isMapExpanded);
                      },
                      child: Icon(
                        _isMapExpanded
                            ? Icons.close_fullscreen_rounded
                            : Icons.open_in_full_rounded,
                        size: 18,
                      ),
                    ),
                  ),

                  // Recenter button
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_map',
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.iconPrimary,
                      onPressed: () {
                        if (booking.pickup != null) {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              booking.pickup!.coordinates,
                              14,
                            ),
                          );
                        }
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                                      booking.pickup?.title ??
                                          'Determining GPS position...',
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: booking.pickup != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              if (booking.destination != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.swap_vert_rounded,
                                    color: AppColors.iconSecondary,
                                  ),
                                  onPressed: () => bookingNotifier
                                      .swapPickupAndDestination(),
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
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
                                            style: AppTypography.labelSmall
                                                .copyWith(
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

                          const Divider(
                            color: AppColors.borderSubtle,
                            height: 20,
                          ),

                          // Destination row (Tap to open Drop Location Picker)
                          InkWell(
                            onTap: _openDropLocationPicker,
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              child: Row(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Drop-off',
                                              style: AppTypography.labelSmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textTertiary,
                                                  ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'TAP TO SELECT',
                                                style: AppTypography.labelSmall
                                                    .copyWith(
                                                      color: AppColors.primary,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 0.5,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          booking.destination?.title ?? 'Select destination or tap on map',
                                          style: AppTypography.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color:
                                                    booking.destination != null
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
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                      ),
                                      icon: const Icon(Icons.add, size: 16),
                                      label: const Text(
                                        'Add Stop',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      onPressed: _showAddStopDialog,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search input for destinations
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search landmark or street...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.iconSecondary,
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dedicated Option to Pick Destination from Map
                    InkWell(
                      onTap: () {
                        setState(() => _isMapExpanded = true);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '📍 Tap anywhere on the map above to pin your destination',
                            ),
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSecondary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primarySoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.map_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Choose Destination on Map',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Tap anywhere on the map to set drop-off pin',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.touch_app_outlined,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _searchController.text.trim().isEmpty
                          ? 'Nearby Suggestions'
                          : 'Search Results',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dynamic Suggestions or Search Results
                    if (_filteredDestinations.isEmpty && !_isSearching)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'No locations found for "${_searchController.text}"'
                                : 'Search places above or tap on map to pick destination',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
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
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              bookingNotifier.setDestination(item);
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  item.coordinates,
                                  13,
                                ),
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
                  label: booking.destination == null
                      ? 'Select Destination to Proceed'
                      : 'View Ride Options',
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
      ),
    );
  }
}
