import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/feed/domain/repositories/feed_repository.dart';

class GetEventsUseCase {
  final FeedRepository _repository;
  GetEventsUseCase(this._repository);

  Future<List<Event>> call() => _repository.getEvents();
}
