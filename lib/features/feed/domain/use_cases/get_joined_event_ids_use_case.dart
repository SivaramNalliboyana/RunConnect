import 'package:runconnect/features/feed/domain/repositories/feed_repository.dart';

class GetJoinedEventIdsUseCase {
  final FeedRepository _repository;
  GetJoinedEventIdsUseCase(this._repository);

  Future<Set<String>> call() => _repository.getJoinedEventIds();
}
