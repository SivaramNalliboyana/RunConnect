import 'dart:typed_data';

import 'package:runconnect/core/error/failures.dart';
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
    double? lat,
    double? lng,
    Uint8List? imageBytes,
    String? imageMimeType,
  }) async {
    try {
      return await _dataSource.createEvent(
        title: title,
        distanceKm: distanceKm,
        maxParticipants: maxParticipants,
        paceLevel: paceLevel,
        startsAt: startsAt,
        meetingPoint: meetingPoint,
        lat: lat,
        lng: lng,
        imageBytes: imageBytes,
        imageMimeType: imageMimeType,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Event> updateEvent({
    required String eventId,
    required String title,
    required double distanceKm,
    required int maxParticipants,
    required PaceLevel paceLevel,
    required DateTime startsAt,
    required String meetingPoint,
    double? lat,
    double? lng,
  }) async {
    try {
      return await _dataSource.updateEvent(
        eventId: eventId,
        title: title,
        distanceKm: distanceKm,
        maxParticipants: maxParticipants,
        paceLevel: paceLevel,
        startsAt: startsAt,
        meetingPoint: meetingPoint,
        lat: lat,
        lng: lng,
      );
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _dataSource.deleteEvent(eventId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> joinEvent(String eventId) async {
    try {
      await _dataSource.joinEvent(eventId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> leaveEvent(String eventId) async {
    try {
      await _dataSource.leaveEvent(eventId);
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
