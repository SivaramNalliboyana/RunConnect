abstract class MapEvent {
  const MapEvent();
}

class MapLocationChanged extends MapEvent {
  final double lat;
  final double lng;
  const MapLocationChanged({required this.lat, required this.lng});
}

class MapRadiusChanged extends MapEvent {
  final int radiusKm;
  const MapRadiusChanged(this.radiusKm);
}

class MapRetryRequested extends MapEvent {
  const MapRetryRequested();
}
