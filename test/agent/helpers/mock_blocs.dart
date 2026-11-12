import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_bloc.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_event.dart';
import 'package:pathfinder_albania/agent/features/trips/bloc/trips_state.dart';

/// `MockBloc<E, S>` lets `whenListen(...)` script a synthetic stream of
/// states without constructing a real bloc. Used by widget tests that
/// just need to render against a known state, not exercise the bloc.
class MockTripsBloc extends MockBloc<TripsEvent, TripsState>
    implements TripsBloc {}

class _FakeTripsEvent extends Fake implements TripsEvent {}

void registerTripsBlocFallbacks() {
  registerFallbackValue(_FakeTripsEvent());
  registerFallbackValue(const TripsState());
}
