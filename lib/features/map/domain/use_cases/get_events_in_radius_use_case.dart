import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/map/domain/repositories/map_repository.dart';

class GetEventsInRadiusUseCase {
  final MapRepository _repository;
  GetEventsInRadiusUseCase(this._repository);

  Future<List<Event>> call({
    required double lat,
    required double lng,
    required double radiusKm,
  }) {
    return _repository.getEventsInRadius(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );
  }
}
