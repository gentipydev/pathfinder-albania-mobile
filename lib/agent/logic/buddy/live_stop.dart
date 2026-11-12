import 'package:equatable/equatable.dart';
import 'package:pathfinder_albania/agent/domain/entities/itinerary_draft.dart';

/// One stop streamed live from Claude's `emit_itinerary` tool call, geocoded
/// server-side and shipped as an `event: itinerary_stop` SSE frame while the
/// reply is still streaming.
///
/// Lean by design: the backend sends only what the live map and the chat row
/// need. Photos, ratings and canonical addresses are backfilled on Save, never
/// here. Mirrors the `LiveStop` interface in the web client
/// (`travel-buddy-web/lib/api/sse.ts`).
class LiveStop extends Equatable {
  const LiveStop({
    required this.id,
    required this.index,
    required this.dayNumber,
    required this.sortOrder,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lng,
    this.dayTitle,
    this.city,
    this.description,
  });

  /// Server-assigned `live-{day_number}-{sort_order}` id. The
  /// `itinerary_routes` frame keys its legs by these exact ids, so they must
  /// survive unchanged onto the live [Trip]'s stops or the polylines orphan.
  final String id;

  /// 1-based arrival order across the whole trip, not per day. Rendered as the
  /// numbered chip on the row, matching the map marker's number.
  final int index;
  final int dayNumber;
  final String? dayTitle;
  final int sortOrder;
  final String name;
  final StopKind kind;
  final String? city;

  /// Per-stop prose from the tool's `notes`, streamed so the row's description
  /// lands in lockstep with its marker.
  final String? description;
  final double lat;
  final double lng;

  /// Returns null when the frame carries no usable id, name, or coordinates.
  /// A stop we cannot place is a stop we cannot map, and the caller drops it
  /// rather than dropping a marker at (0, 0) in the Gulf of Guinea.
  static LiveStop? tryParse(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    final name = ((json['name'] as String?) ?? '').trim();
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    if (id.isEmpty || name.isEmpty || lat == null || lng == null) return null;
    return LiveStop(
      id: id,
      index: _asInt(json['index'], 0),
      dayNumber: _asInt(json['day_number'], 1).clamp(1, 1 << 30),
      dayTitle: json['day_title'] as String?,
      sortOrder: _asInt(json['sort_order'], 0),
      name: name,
      kind: stopKindFromString(json['kind'] as String?),
      city: json['city'] as String?,
      description: json['description'] as String?,
      lat: lat,
      lng: lng,
    );
  }

  static int _asInt(Object? raw, int fallback) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw') ?? fallback;
  }

  @override
  List<Object?> get props => [
        id,
        index,
        dayNumber,
        dayTitle,
        sortOrder,
        name,
        kind,
        city,
        description,
        lat,
        lng,
      ];
}
