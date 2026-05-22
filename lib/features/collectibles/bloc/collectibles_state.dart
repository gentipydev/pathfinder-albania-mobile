import 'package:equatable/equatable.dart';

class CollectiblesState extends Equatable {
  const CollectiblesState({
    this.statesById = const {},
    this.discoveredCount = 0,
    this.exploredCount = 0,
    this.isLoaded = false,
  });

  final Map<String, int> statesById;
  final int discoveredCount;
  final int exploredCount;
  final bool isLoaded;

  CollectiblesState copyWith({
    Map<String, int>? statesById,
    int? discoveredCount,
    int? exploredCount,
    bool? isLoaded,
  }) =>
      CollectiblesState(
        statesById: statesById ?? this.statesById,
        discoveredCount: discoveredCount ?? this.discoveredCount,
        exploredCount: exploredCount ?? this.exploredCount,
        isLoaded: isLoaded ?? this.isLoaded,
      );

  @override
  List<Object?> get props =>
      [statesById, discoveredCount, exploredCount, isLoaded];
}
