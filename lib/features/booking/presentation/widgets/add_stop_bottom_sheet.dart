import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/services/location_search_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/location_item.dart';

class AddStopBottomSheet extends ConsumerStatefulWidget {
  final LatLng pickupCoordinates;
  final ValueChanged<LocationItem> onStopSelected;

  const AddStopBottomSheet({
    super.key,
    required this.pickupCoordinates,
    required this.onStopSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required LatLng pickupCoordinates,
    required ValueChanged<LocationItem> onStopSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddStopBottomSheet(
        pickupCoordinates: pickupCoordinates,
        onStopSelected: onStopSelected,
      ),
    );
  }

  @override
  ConsumerState<AddStopBottomSheet> createState() => _AddStopBottomSheetState();
}

class _AddStopBottomSheetState extends ConsumerState<AddStopBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;
  bool _isLoading = false;
  List<LocationItem> _results = [];
  List<LocationItem> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadDynamicSuggestions();
  }

  Future<void> _loadDynamicSuggestions() async {
    setState(() => _isLoading = true);
    final nearby = await ref
        .read(locationSearchServiceProvider)
        .getNearbySuggestions(widget.pickupCoordinates);
    if (mounted) {
      setState(() {
        _isLoading = false;
        _suggestions = nearby;
        if (_controller.text.isEmpty) {
          _results = nearby;
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      setState(() {
        _isLoading = false;
        _results = _suggestions;
      });
      return;
    }

    // 1. Quick local filtering for instantaneous feedback
    final localMatches = _suggestions
        .where((item) =>
            item.title.toLowerCase().contains(trimmed.toLowerCase()) ||
            item.subtitle.toLowerCase().contains(trimmed.toLowerCase()))
        .toList();

    if (localMatches.isNotEmpty) {
      setState(() {
        _results = localMatches;
      });
    }

    // 2. Real geocoding search with debounce
    setState(() => _isLoading = true);
    _debounceTimer = Timer(const Duration(milliseconds: 380), () async {
      try {
        final searchService = ref.read(locationSearchServiceProvider);
        final realResults = await searchService.search(
          trimmed,
          proximity: widget.pickupCoordinates,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            if (realResults.isNotEmpty) {
              _results = realResults;
            } else if (localMatches.isEmpty) {
              _results = [];
            }
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: bottomInset > 0 ? bottomInset + 16 : 32,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
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

            // Sheet Title
            Text(
              'Add Intermediate Stop',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search real places, landmarks, and addresses',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                autofocus: false,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search landmark, area, or street...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _controller.clear();
                                _onQueryChanged('');
                              },
                            )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section Header
            Text(
              _controller.text.trim().isEmpty
                  ? 'Nearby Suggestions'
                  : 'Search Results',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Results List
            Expanded(
              child: _results.isEmpty && !_isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off_outlined,
                            size: 44,
                            color: AppColors.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No locations found for "${_controller.text}"',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AppColors.borderSubtle, height: 1),
                      itemBuilder: (context, index) {
                        final item = _results[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFF59E0B),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.subtitle,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            widget.onStopSelected(item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
