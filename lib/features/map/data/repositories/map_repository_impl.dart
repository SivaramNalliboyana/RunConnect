import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/map/data/data_sources/map_remote_data_source.dart';
import 'package:runconnect/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource _dataSource;
  MapRepositoryImpl(this._dataSource);

  @override
  Future<List<Event>> getEventsInRadius({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      return await _dataSource.getEventsInRadius(
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
