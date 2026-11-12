import 'package:equatable/equatable.dart';
import 'package:pathfinder_albania/logic/data/artifact_data.dart';
import 'package:pathfinder_albania/logic/data/destination_artifacts.dart';
import 'package:pathfinder_albania/logic/data/destination_type.dart';

class ArtifactsState extends Equatable {
  const ArtifactsState({
    this.byDestination = const {},
    this.byId = const {},
    this.dataVersion = 0,
  });

  final Map<DestinationType, DestinationArtifacts> byDestination;
  final Map<String, ArtifactData> byId;
  final int dataVersion;

  ArtifactsState copyWith({
    Map<DestinationType, DestinationArtifacts>? byDestination,
    Map<String, ArtifactData>? byId,
    int? dataVersion,
  }) =>
      ArtifactsState(
        byDestination: byDestination ?? this.byDestination,
        byId: byId ?? this.byId,
        dataVersion: dataVersion ?? this.dataVersion,
      );

  @override
  List<Object?> get props => [byDestination, byId, dataVersion];
}
