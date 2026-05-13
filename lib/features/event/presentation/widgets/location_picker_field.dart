import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/core/theme/app_text_styles.dart';

class LocationPickerField extends StatefulWidget {
  const LocationPickerField({
    super.key,
    required this.controller,
    required this.onLatLngChanged,
    this.initialLat,
    this.initialLng,
  });

  final TextEditingController controller;
  final double? initialLat;
  final double? initialLng;
  final void Function(double? lat, double? lng) onLatLngChanged;

  @override
  State<LocationPickerField> createState() => _LocationPickerFieldState();
}

class _LocationPickerFieldState extends State<LocationPickerField> {
  static const _fallbackLat = 30.2672;
  static const _fallbackLng = -97.7431;

  Timer? _debounce;
  List<_Place> _suggestions = const [];
  bool _searching = false;
  bool _locating = false;
  bool _suppressNextSearch = false;

  MapboxMap? _mapbox;
  CircleAnnotationManager? _annotations;
  CircleAnnotation? _pin;

  double? _lat;
  double? _lng;

  @override
  void initState() {
    super.initState();
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onTextChanged() {
    if (_suppressNextSearch) {
      _suppressNextSearch = false;
      return;
    }
    _debounce?.cancel();
    final query = widget.controller.text.trim();
    if (query.length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _runSearch(query);
    });
  }

  Future<void> _runSearch(String query) async {
    final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'];
    if (token == null || token.isEmpty) return;
    setState(() => _searching = true);
    try {
      final encoded = Uri.encodeComponent(query);
      final proximity = (_lat != null && _lng != null)
          ? '&proximity=$_lng,$_lat'
          : '';
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$encoded.json'
        '?access_token=$token&autocomplete=true&limit=5$proximity',
      );
      final res = await http.get(uri);
      if (!mounted) return;
      if (res.statusCode != 200) {
        setState(() => _suggestions = const []);
        return;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? const [];
      final places = features.map((f) {
        final m = f as Map<String, dynamic>;
        final coords = (m['center'] as List).cast<num>();
        return _Place(
          name: m['place_name'] as String,
          lng: coords[0].toDouble(),
          lat: coords[1].toDouble(),
        );
      }).toList();
      setState(() => _suggestions = places);
    } catch (_) {
      if (mounted) setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _selectPlace(_Place place) async {
    _suppressNextSearch = true;
    widget.controller.text = place.name;
    widget.controller.selection = TextSelection.collapsed(
      offset: place.name.length,
    );
    setState(() {
      _suggestions = const [];
      _lat = place.lat;
      _lng = place.lng;
    });
    widget.onLatLngChanged(place.lat, place.lng);
    await _placePin(place.lat, place.lng, animate: true);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  Future<void> _useCurrentLocation() async {
    if (kIsWeb) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!enabled) {
        _snack('Turn on location services to use this');
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (!mounted) return;
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (!mounted) return;
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _snack('Location permission denied');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final name = await _reverseGeocode(pos.latitude, pos.longitude);
      if (!mounted) return;
      _suppressNextSearch = true;
      widget.controller.text = name ?? 'Current location';
      widget.controller.selection = TextSelection.collapsed(
        offset: widget.controller.text.length,
      );
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _suggestions = const [];
      });
      widget.onLatLngChanged(pos.latitude, pos.longitude);
      await _placePin(pos.latitude, pos.longitude, animate: true);
    } catch (e) {
      if (mounted) _snack('Could not get location');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<String?> _reverseGeocode(double lat, double lng) async {
    final token = dotenv.env['MAPBOX_PUBLIC_TOKEN'];
    if (token == null || token.isEmpty) return null;
    try {
      final uri = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json'
        '?access_token=$token&limit=1',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final features = (json['features'] as List?) ?? const [];
      if (features.isEmpty) return null;
      return (features.first as Map<String, dynamic>)['place_name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _mapbox = map;
    _annotations = await map.annotations.createCircleAnnotationManager();
    if (_lat != null && _lng != null) {
      await _placePin(_lat!, _lng!, animate: false);
    }
  }

  Future<void> _placePin(double lat, double lng, {required bool animate}) async {
    final mgr = _annotations;
    final map = _mapbox;
    if (mgr == null || map == null) return;

    if (_pin != null) {
      await mgr.delete(_pin!);
      _pin = null;
    }
    _pin = await mgr.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(lng, lat)),
        circleRadius: 9,
        circleColor: 0xFF1B3D2F,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 3,
      ),
    );

    final camera = CameraOptions(
      center: Point(coordinates: Position(lng, lat)),
      zoom: 14,
    );
    if (animate) {
      await map.flyTo(camera, MapAnimationOptions(duration: 800));
    } else {
      await map.setCamera(camera);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meeting Point', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: 'Search for a location...',
            hintStyle: AppTextStyles.bodyMuted,
            prefixIcon: const Icon(
              Icons.location_on,
              size: 20,
              color: AppColors.primary,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 36),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 12,
            ),
          ),
        ),
        if (!kIsWeb) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _locating ? null : _useCurrentLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: const Text('Use current location'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _suggestions.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: Colors.black12),
                  InkWell(
                    onTap: () => _selectPlace(_suggestions[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _suggestions[i].name,
                              style: AppTextStyles.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 180,
            child: kIsWeb ? _webFallback() : _mapView(),
          ),
        ),
      ],
    );
  }

  Widget _mapView() {
    return MapWidget(
      key: const ValueKey('location-picker-map'),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            _lng ?? _fallbackLng,
            _lat ?? _fallbackLat,
          ),
        ),
        zoom: (_lat != null && _lng != null) ? 14 : 10,
      ),
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
    );
  }

  Widget _webFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6FA1B5), Color(0xFF8AB58A)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.location_on, color: AppColors.primary, size: 36),
      ),
    );
  }

  static OutlineInputBorder _border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.black12),
  );
}

class _Place {
  const _Place({required this.name, required this.lat, required this.lng});
  final String name;
  final double lat;
  final double lng;
}
