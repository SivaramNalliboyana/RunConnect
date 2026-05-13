import 'package:runconnect/features/event/domain/entities/event.dart';

enum MapStatus { initial, loading, success, failure }

class MapState {
  final MapStatus status;
  final List<Event> events;
  final int radiusKm;
  final double? anchorLat;
  final double? anchorLng;
  final String? errorMessage;

  const MapState({
    this.status = MapStatus.initial,
    this.events = const [],
    this.radiusKm = 25,
    this.anchorLat,
    this.anchorLng,
    this.errorMessage,
  });

  const MapState.initial() : this();

  MapState copyWith({
    MapStatus? status,
    List<Event>? events,
    int? radiusKm,
    double? anchorLat,
    double? anchorLng,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MapState(
      status: status ?? this.status,
      events: events ?? this.events,
      radiusKm: radiusKm ?? this.radiusKm,
      anchorLat: anchorLat ?? this.anchorLat,
      anchorLng: anchorLng ?? this.anchorLng,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
