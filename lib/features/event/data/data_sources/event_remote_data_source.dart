import 'package:image_picker/image_picker.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class EventRemoteDataSource {
  Future<Event> createEvent({
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    XFile? image,
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SupabaseClient _client;
  EventRemoteDataSourceImpl(this._client);

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
