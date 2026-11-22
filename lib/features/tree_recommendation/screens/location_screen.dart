import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/primary_button.dart';
import '../models/land_location.dart';
import '../services/location_service.dart';
import '../widgets/tree_screen_scaffold.dart';
import 'soil_input_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _queryController = TextEditingController();
  final _locationService = LocationService();
  List<LandLocation> _results = const [];
  LandLocation? _selected;
  String? _error;
  bool _searching = false;
  bool _locating = false;

  @override
  void dispose() {
    _queryController.dispose();
    _locationService.close();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Enter a town, city, or address to search.');
      return;
    }
    setState(() {
      _searching = true;
      _error = null;
      _results = const [];
    });
    try {
      final results = await _locationService.search(query);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) {
          _error = 'No locations found. Try a nearby town or city.';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error =
            'Could not search locations. Check your connection and try again.');
      }
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      final location = await _locationService.currentLocation();
      if (mounted) setState(() => _selected = location);
    } on LocationPermissionDeniedException {
      if (mounted) {
        setState(() => _error =
            'Location permission was denied. Allow access or search for a place.');
      }
    } on LocationPermissionDeniedForeverException {
      if (mounted) {
        setState(() => _error =
            'Location permission is disabled for this app. Enable it in device settings or search for a place.');
      }
    } on LocationServiceDisabledException {
      if (mounted) {
        setState(
            () => _error = 'Turn on location services or search for a place.');
      }
    } on LocationAddressNotFoundException {
      if (mounted) {
        setState(() =>
            _error = 'Unable to detect your location. Please search manually.');
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'Unable to detect your location. Please search manually.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _continue() {
    final location = _selected;
    if (location == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (_) => SoilInputScreen(location: location)),
    );
  }

  @override
  Widget build(BuildContext context) => TreeScreenScaffold(
        title: 'Select Land Location',
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            const Text('Where is your land?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dark)),
            const SizedBox(height: 8),
            const Text(
                'Choose your land location to retrieve local climate data.',
                style: TextStyle(color: AppColors.muted, height: 1.45)),
            const SizedBox(height: 20),
            TreeInfoCard(
              child: InkWell(
                onTap: _locating ? null : _useCurrentLocation,
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.farmTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: AppColors.farmAccent),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Use Current Location',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark)),
                          SizedBox(height: 3),
                          Text('Detect your location from device GPS',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (_locating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.muted),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TreeInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Search Location',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _search(),
                          decoration: const InputDecoration(
                            hintText: 'Search your land location',
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _searching ? null : _search,
                        icon: _searching
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.search_rounded),
                        style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style:
                      const TextStyle(color: Color(0xFFB3261E), fontSize: 13)),
            ],
            if (_results.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Search results',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.dark)),
              const SizedBox(height: 8),
              for (final location in _results)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: const Icon(Icons.place_outlined,
                      color: AppColors.farmAccent),
                  title: Text(location.name,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  tileColor: AppColors.white,
                  onTap: () => setState(() {
                    _selected = location;
                    _results = const [];
                  }),
                ),
            ],
            if (_selected != null) ...[
              const SizedBox(height: 20),
              TreeInfoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selected!.label,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 6),
                    Text(_selected!.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Continue',
                onPressed: _selected == null ? null : _continue),
          ],
        ),
      );
}
