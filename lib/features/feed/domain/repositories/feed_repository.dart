import 'package:runconnect/features/event/domain/entities/event.dart';

abstract class FeedRepository {
  Future<List<Event>> getEvents();
  Future<Set<String>> getJoinedEventIds();
}
