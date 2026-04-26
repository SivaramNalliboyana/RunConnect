import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/data/data_sources/event_remote_data_source.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/event/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource _dataSource;
  EventRepositoryImpl(this._dataSource);

  @override
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    XFile? image,
  }) {
    throw UnimplementedError();
  }
}
