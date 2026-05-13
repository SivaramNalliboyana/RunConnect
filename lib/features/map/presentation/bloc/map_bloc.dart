import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:runconnect/core/error/failures.dart';
import 'package:runconnect/features/map/domain/use_cases/get_events_in_radius_use_case.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetEventsInRadiusUseCase _getEventsInRadius;

  MapBloc({required GetEventsInRadiusUseCase getEventsInRadius})
    : _getEventsInRadius = getEventsInRadius,
      super(const MapState.initial()) {
    on<MapLocationChanged>(_onLocationChanged);
    on<MapRadiusChanged>(_onRadiusChanged);
    on<MapRetryRequested>(_onRetryRequested);
  }

  Future<void> _onLocationChanged(
    MapLocationChanged event,
    Emitter<MapState> emit,
  ) async {
    emit(
      state.copyWith(
        anchorLat: event.lat,
        anchorLng: event.lng,
        clearError: true,
      ),
    );
    await _fetch(emit);
  }

  Future<void> _onRadiusChanged(
    MapRadiusChanged event,
    Emitter<MapState> emit,
  ) async {
    if (event.radiusKm == state.radiusKm) return;
    emit(state.copyWith(radiusKm: event.radiusKm, clearError: true));
    await _fetch(emit);
  }

  Future<void> _onRetryRequested(
    MapRetryRequested event,
    Emitter<MapState> emit,
  ) async {
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<MapState> emit) async {
    final lat = state.anchorLat;
    final lng = state.anchorLng;
    if (lat == null || lng == null) return;

    emit(state.copyWith(status: MapStatus.loading, clearError: true));
    try {
      final events = await _getEventsInRadius(
        lat: lat,
        lng: lng,
        radiusKm: state.radiusKm.toDouble(),
      );
      emit(state.copyWith(status: MapStatus.success, events: events));
    } on Failure catch (e) {
      emit(state.copyWith(status: MapStatus.failure, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          status: MapStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
