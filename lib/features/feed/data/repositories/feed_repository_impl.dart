import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/event/domain/entities/event.dart';
import 'package:runconnect/features/feed/data/data_sources/feed_remote_data_source.dart';
import 'package:runconnect/features/feed/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _dataSource;
  FeedRepositoryImpl(this._dataSource);

  @override
  Future<List<Event>> getEvents() async {
    try {
      return await _dataSource.getEvents();
    } on ServerFailure {
      rethrow;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
