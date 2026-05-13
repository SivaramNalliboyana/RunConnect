import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart' hide Position;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide LocationSettings;
import 'package:runconnect/core/theme/app_colors.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/map/data/data_sources/map_remote_data_source.dart';
import 'package:runconnect/features/map/data/repositories/map_repository_impl.dart';
import 'package:runconnect/features/map/domain/use_cases/get_events_in_radius_use_case.dart';
import 'package:runconnect/features/map/presentation/bloc/map_bloc.dart';
import 'package:runconnect/features/map/presentation/bloc/map_event.dart';
import 'package:runconnect/features/map/presentation/bloc/map_state.dart';
import 'package:runconnect/features/map/presentation/widgets/address_search_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _buildBloc(),
      child: const _MapView(),
    );
  }

  static MapBloc _buildBloc() {
    final client = Supabase.instance.client;
    final repository = MapRepositoryImpl(MapRemoteDataSourceImpl(client));
    return MapBloc(getEventsInRadius: GetEventsInRadiusUseCase(repository));
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  // Berlin centre — used as initial camera before we have GPS.
  static const _fallbackLat = 52.5200;
  static const _fallbackLng = 13.4050;

  static const _radiusOptions = [25, 50, 100];

  // A single shared viewport instance. MapWidget rebuilds reassert the
  // camera every time the viewport REFERENCE changes — so we hand it the
  // same instance forever and drive the camera ourselves via flyTo.
  static final _initialViewport = CameraViewportState(
    center: Point(coordinates: Position(_fallbackLng, _fallbackLat)),
    zoom: 11,
  );

  MapboxMap? _mapbox;
  PointAnnotationManager? _annotations;
  final Map<String, Event> _annotationToEvent = {};
  final TextEditingController _searchController = TextEditingController();
  Uint8List? _pinPng;
  Event? _selectedEvent;
  bool _locating = false;
  bool _showSearchHere = false;
  double? _camLat;
  double? _camLng;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _locateUser());
    }
  }

  static const _fixFreshness = Duration(seconds: 60);
  static const _meaningfulShiftMeters = 200.0;
  DateTime? _lastFixAt;
  // The user's most recently known GPS position, kept independently from the
  // bloc anchor so a search doesn't lose track of where the user actually is.
  double? _myLat;
  double? _myLng;

  Future<void> _locateUser() async {
    final bloc = context.read<MapBloc>();
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }

    // Fast path: we know where the user is. Fly there now, sync the bloc
    // anchor if a search moved it, and skip GPS entirely when fresh.
    if (_myLat != null && _myLng != null) {
      final myLat = _myLat!;
      final myLng = _myLng!;
      final cur = bloc.state;
      if (cur.anchorLat != myLat || cur.anchorLng != myLng) {
        bloc.add(MapLocationChanged(lat: myLat, lng: myLng));
      }
      // ignore: discarded_futures
      _flyTo(myLat, myLng);

      if (_lastFixAt != null &&
          DateTime.now().difference(_lastFixAt!) < _fixFreshness) {
        return;
      }
      // Stale — fall through and refresh in the background.
    }

    if (_locating) return;
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      // First-ever locate: prime _myLat from the OS's last-known position so
      // we have *something* to fly to while the fresh fix loads. Stale by
      // design — we deliberately don't set _lastFixAt here.
      if (_myLat == null) {
        try {
          final last = await Geolocator.getLastKnownPosition();
          if (!mounted) return;
          if (last != null) {
            _myLat = last.latitude;
            _myLng = last.longitude;
            bloc.add(
              MapLocationChanged(lat: last.latitude, lng: last.longitude),
            );
            // ignore: discarded_futures
            _flyTo(last.latitude, last.longitude);
          }
        } catch (_) {
          // No cached position — fall through to the fresh fix.
        }
      }

      // Fresh fix. Medium accuracy + 15 s timeout is the right balance for
      // a "near me / 25 km radius" use case.
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      _lastFixAt = DateTime.now();

      final prevLat = _myLat;
      final prevLng = _myLng;
      _myLat = fresh.latitude;
      _myLng = fresh.longitude;

      final shiftFromStored = (prevLat == null || prevLng == null)
          ? double.infinity
          : Geolocator.distanceBetween(
              prevLat,
              prevLng,
              fresh.latitude,
              fresh.longitude,
            );
      final cur = bloc.state;
      final blocDiffers =
          cur.anchorLat == null ||
          cur.anchorLng == null ||
          Geolocator.distanceBetween(
                cur.anchorLat!,
                cur.anchorLng!,
                fresh.latitude,
                fresh.longitude,
              ) >
              _meaningfulShiftMeters;

      if (shiftFromStored > _meaningfulShiftMeters || blocDiffers) {
        bloc.add(
          MapLocationChanged(lat: fresh.latitude, lng: fresh.longitude),
        );
        // ignore: discarded_futures
        _flyTo(fresh.latitude, fresh.longitude);
      }
    } catch (_) {
      // Silent — keep showing whatever anchor we already have.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _flyTo(double lat, double lng) async {
    final map = _mapbox;
    if (map == null) return;
    await map.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 12,
      ),
      MapAnimationOptions(duration: 800),
    );
  }

  Future<void> _onMapCreated(MapboxMap map) async {
    _mapbox = map;

    // Enable the standard Mapbox location puck — blue dot + accuracy ring.
    // No-op gracefully if location permission isn't granted yet.
    try {
      await map.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: true,
          showAccuracyRing: true,
        ),
      );
    } catch (_) {
      // Some emulators / older OS versions throw — non-critical.
    }

    final mgr = await map.annotations.createPointAnnotationManager();
    mgr.tapEvents(onTap: (annotation) => _onMarkerTap(annotation.id));
    _annotations = mgr;
    if (!mounted) return;
    final events = context.read<MapBloc>().state.events;
    if (events.isNotEmpty) {
      await _renderMarkers(events);
    }
  }

  Future<void> _renderMarkers(List<Event> events) async {
    final mgr = _annotations;
    if (mgr == null) return;

    await mgr.deleteAll();
    _annotationToEvent.clear();

    final eventsWithCoords = events
        .where((e) => e.lat != null && e.lng != null)
        .toList(growable: false);
    if (eventsWithCoords.isEmpty) return;

    final png = _pinPng ?? await _buildPinPng();
    _pinPng = png;

    final options = eventsWithCoords
        .map(
          (e) => PointAnnotationOptions(
            geometry: Point(coordinates: Position(e.lng!, e.lat!)),
            image: png,
            iconAnchor: IconAnchor.CENTER,
          ),
        )
        .toList(growable: false);

    final created = await mgr.createMulti(options);
    for (var i = 0; i < created.length; i++) {
      final annotation = created[i];
      if (annotation == null) continue;
      _annotationToEvent[annotation.id] = eventsWithCoords[i];
    }
  }

  Future<Uint8List> _buildPinPng() async {
    // Logical-pixel design: 48 diameter, 3 border, ~26 icon. Rendered at 3x.
    const scale = 3.0;
    const diameter = 48 * scale;
    const border = 3 * scale;
    const iconSize = 26 * scale;
    const shadowPadding = 6 * scale;

    final canvasSize = diameter + shadowPadding * 2;
    final center = Offset(canvasSize / 2, canvasSize / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Soft drop shadow.
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6);
    canvas.drawCircle(center.translate(0, 3), diameter / 2, shadowPaint);

    // White outer ring.
    final ringPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, diameter / 2, ringPaint);

    // Brand-green disc.
    final discPaint = Paint()..color = const Color(0xFF1B3D2F);
    canvas.drawCircle(center, diameter / 2 - border, discPaint);

    // Runner icon, centered.
    const runnerIcon = Icons.directions_run;
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(runnerIcon.codePoint),
        style: TextStyle(
          fontFamily: runnerIcon.fontFamily,
          package: runnerIcon.fontPackage,
          color: Colors.white,
          fontSize: iconSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      canvasSize.toInt(),
      canvasSize.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _onMarkerTap(String annotationId) {
    final event = _annotationToEvent[annotationId];
    if (event == null) return;
    setState(() => _selectedEvent = event);
    final lat = event.lat;
    final lng = event.lng;
    if (lat != null && lng != null) {
      _flyTo(lat, lng);
    }
  }

  void _closePreview() {
    setState(() => _selectedEvent = null);
  }

  Future<void> _onMapIdle(MapIdleEventData _) async {
    final map = _mapbox;
    if (map == null || !mounted) return;
    try {
      final cam = await map.getCameraState();
      if (!mounted) return;
      _camLat = cam.center.coordinates.lat.toDouble();
      _camLng = cam.center.coordinates.lng.toDouble();
    } catch (_) {
      return;
    }

    final state = context.read<MapBloc>().state;
    if (state.anchorLat == null || state.anchorLng == null) return;

    final shift = Geolocator.distanceBetween(
      state.anchorLat!,
      state.anchorLng!,
      _camLat!,
      _camLng!,
    );
    // Show the prompt once the camera has drifted past ~30% of the active
    // radius — about a screen-width on most zoom levels.
    final threshold = state.radiusKm * 1000 * 0.3;
    final shouldShow = shift > threshold;
    if (shouldShow != _showSearchHere) {
      setState(() => _showSearchHere = shouldShow);
    }
  }

  void _refetchAtCamera() {
    final lat = _camLat;
    final lng = _camLng;
    if (lat == null || lng == null) return;
    if (_searchController.text.isNotEmpty) {
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
    context.read<MapBloc>().add(MapLocationChanged(lat: lat, lng: lng));
    setState(() {
      _showSearchHere = false;
      _selectedEvent = null;
    });
  }

  void _onAddressPicked(double lat, double lng, String placeName) {
    setState(() => _selectedEvent = null);
    context.read<MapBloc>().add(MapLocationChanged(lat: lat, lng: lng));
    _flyTo(lat, lng);
  }

  bool _hasStatusPill(MapState state) {
    if (kIsWeb) return false;
    if (state.anchorLat == null && !_locating) return true;
    if (state.status == MapStatus.failure) return true;
    return false;
  }

  Widget _buildStatusPill(BuildContext context, MapState state) {
    if (state.anchorLat == null && !_locating) {
      return _StatusPill(
        icon: Icons.location_off_outlined,
        text: 'Enable location to discover events nearby',
        onTap: _locateUser,
      );
    }
    if (state.status == MapStatus.failure) {
      return _StatusPill(
        icon: Icons.error_outline,
        text: 'Couldn\'t load events. Tap to retry.',
        tone: _PillTone.error,
        onTap: () =>
            context.read<MapBloc>().add(const MapRetryRequested()),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<MapBloc, MapState>(
        listenWhen: (prev, curr) => prev.events != curr.events,
        listener: (context, state) {
          _renderMarkers(state.events);
          final selected = _selectedEvent;
          if (selected != null &&
              !state.events.any((e) => e.id == selected.id)) {
            setState(() => _selectedEvent = null);
          }
        },
        builder: (context, state) {
          final hasPreview = _selectedEvent != null;
          return Stack(
            children: [
              Positioned.fill(child: kIsWeb ? _webFallback() : _mapView()),
              Positioned(
                top: insets.top + 12,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AddressSearchField(
                      controller: _searchController,
                      onPicked: _onAddressPicked,
                      proximityLat: state.anchorLat,
                      proximityLng: state.anchorLng,
                    ),
                    const SizedBox(height: 8),
                    _RadiusChips(
                      options: _radiusOptions,
                      selected: state.radiusKm,
                      onChanged: (km) => context
                          .read<MapBloc>()
                          .add(MapRadiusChanged(km)),
                    ),
                    if (_hasStatusPill(state)) ...[
                      const SizedBox(height: 8),
                      _buildStatusPill(context, state),
                    ],
                    if (_showSearchHere) ...[
                      const SizedBox(height: 10),
                      Center(
                        child: _SearchHereButton(onTap: _refetchAtCamera),
                      ),
                    ],
                  ],
                ),
              ),
              if (!kIsWeb)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  right: 16,
                  bottom: insets.bottom + (hasPreview ? 136 : 16),
                  child: FloatingActionButton(
                    onPressed: _locateUser,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 4,
                    child: const Icon(Icons.my_location),
                  ),
                ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                left: 16,
                right: 16,
                bottom: hasPreview ? insets.bottom + 16 : -180,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: hasPreview ? 1 : 0,
                  child: _selectedEvent == null
                      ? const SizedBox.shrink()
                      : _EventPreviewCard(
                          event: _selectedEvent!,
                          onClose: _closePreview,
                          onTap: () => context.push(
                            '/event',
                            extra: _selectedEvent,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _mapView() {
    return MapWidget(
      key: const ValueKey('map-page'),
      viewport: _initialViewport,
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onMapIdleListener: _onMapIdle,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Map is not available on the web build.\nOpen the app on Android or iOS to explore events nearby.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadiusChips extends StatelessWidget {
  const _RadiusChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final km in options)
              _Chip(
                label: '$km km',
                selected: km == selected,
                onTap: () => onChanged(km),
              ),
          ],
        ),
      ),
    );
  }
}

enum _PillTone { neutral, error }

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.text,
    this.tone = _PillTone.neutral,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final _PillTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isError = tone == _PillTone.error;
    final iconColor = isError ? AppColors.error : AppColors.primary;
    final textColor = isError ? AppColors.error : AppColors.onBackground;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );

    final pill = Material(
      color: AppColors.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(22),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              child: content,
            ),
    );

    return Align(alignment: Alignment.center, child: pill);
  }
}

class _SearchHereButton extends StatelessWidget {
  const _SearchHereButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: 16,
                color: AppColors.onPrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Search this area',
                style: TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventPreviewCard extends StatelessWidget {
  const _EventPreviewCard({
    required this.event,
    required this.onClose,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onClose;
  final VoidCallback onTap;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';

  String _formatTime(DateTime d) {
    final hour = d.hour == 0 || d.hour == 12 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final suffix = d.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 36, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: _Thumb(imageUrl: event.imageUrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${_formatDate(event.startsAt)} · ${_formatTime(event.startsAt)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.meetingPoint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_run,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${event.distanceKm.toStringAsFixed(event.distanceKm % 1 == 0 ? 0 : 1)} km · ${event.paceLevel.label}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onBackground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) return const _ThumbFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ThumbFallback(),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8EBDC), Color(0xFF8FB89A)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_run,
        size: 32,
        color: AppColors.primary,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.onPrimary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
