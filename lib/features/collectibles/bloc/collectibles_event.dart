import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class CollectiblesEvent extends Equatable {
  const CollectiblesEvent();

  @override
  List<Object?> get props => const [];
}

class CollectiblesLoadRequested extends CollectiblesEvent {
  const CollectiblesLoadRequested({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}

class CollectiblesStateChanged extends CollectiblesEvent {
  const CollectiblesStateChanged({required this.id, required this.state});

  final String id;
  final int state;

  @override
  List<Object?> get props => [id, state];
}

class CollectiblesResetRequested extends CollectiblesEvent {
  const CollectiblesResetRequested();
}

class CollectiblesFlushPendingSaveRequested extends CollectiblesEvent {
  const CollectiblesFlushPendingSaveRequested({this.completer});

  final Completer<void>? completer;

  @override
  List<Object?> get props => [completer];
}
