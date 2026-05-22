import 'package:equatable/equatable.dart';
import 'package:travel_buddy/logic/data/artifact_data.dart';
import 'package:travel_buddy/logic/data/destination_artifacts.dart';
import 'package:travel_buddy/logic/data/destination_type.dart';

abstract class ArtifactsEvent extends Equatable {
  const ArtifactsEvent();

  @override
  List<Object?> get props => const [];
}

/// Internal-only: dispatched from `getForDestination` after a successful fetch
/// to drive the state emit. Never dispatched from outside the bloc.
class ArtifactsDestinationFetchedInternal extends ArtifactsEvent {
  const ArtifactsDestinationFetchedInternal({
    required this.type,
    required this.result,
  });

  final DestinationType type;
  final DestinationArtifacts result;

  @override
  List<Object?> get props => [type, result];
}

/// Internal-only: dispatched from `getById` after a successful single-artifact
/// fetch to drive the state emit. Never dispatched from outside the bloc.
class ArtifactsByIdFetchedInternal extends ArtifactsEvent {
  const ArtifactsByIdFetchedInternal({required this.id, required this.data});

  final String id;
  final ArtifactData data;

  @override
  List<Object?> get props => [id, data];
}
