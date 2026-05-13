import 'package:runconnect/features/event/domain/entities/event.dart';

abstract class MapRepository {
  Future<List<Event>> getEventsInRadius({
    required double lat,
    required double lng,
    required double radiusKm,
  });
}
