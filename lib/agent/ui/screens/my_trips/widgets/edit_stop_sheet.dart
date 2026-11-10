import 'package:travel_buddy/common_libs.dart';
import 'package:travel_buddy/agent/domain/entities/itinerary_draft.dart';
import 'package:travel_buddy/agent/domain/entities/trip_stop.dart';

/// Modal bottom sheet for both adding a new stop and editing an existing
/// one. Returns a JSON-shaped Map ready to send to the backend, or `null`
/// on cancel:
///
/// - Add mode (`initial == null`): full TripStopCreate body.
/// - Edit mode: partial patch with only the fields that differ from
///   `initial`. Snake_case keys in both cases to match the wire format.
class EditStopSheet extends StatefulWidget {
  const EditStopSheet({super.key, this.initial});

  final TripStop? initial;

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    TripStop? initial,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: $styles.colors.greyStrong,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: EditStopSheet(initial: initial),
      ),
    );
  }

  @override
  State<EditStopSheet> createState() => _EditStopSheetState();
}

class _EditStopSheetState extends State<EditStopSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _city = TextEditingController(
    text: widget.initial?.city ?? '',
  );
  late final TextEditingController _address = TextEditingController(
    text: widget.initial?.address ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.initial?.notes ?? '',
  );
  late final TextEditingController _duration = TextEditingController(
    text: widget.initial?.durationMinutes?.toString() ?? '',
  );

  late StopKind _kind = _initialKind();
  late TransportationKind? _transport = _initialTransport();
  String? _arrival;
  String? _endTime;
  bool _showEndTimeError = false;

  StopKind _initialKind() {
    final k = widget.initial?.kind;
    if (k == null || k == StopKind.unknown) return StopKind.activity;
    return k;
  }

  TransportationKind? _initialTransport() {
    final t = widget.initial?.transportation;
    if (t == null || t == TransportationKind.unknown) return null;
    return t;
  }

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _arrival = widget.initial?.arrivalTime;
    _endTime = widget.initial?.endTime;
    _name.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _name.removeListener(_onTextChanged);
    _name.dispose();
    _city.dispose();
    _address.dispose();
    _notes.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  bool get _saveEnabled {
    if (_name.text.trim().isEmpty) return false;
    if (_arrival != null && _endTime != null) {
      if (_compareHHMM(_endTime!, _arrival!) <= 0) return false;
    }
    return true;
  }

  Future<void> _pickTime({required bool isArrival}) async {
    final current = isArrival ? _arrival : _endTime;
    final initial = current != null
        ? _parseHHMM(current) ?? TimeOfDay.now()
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        // Keep MediaQuery's 24h preference as-is so the picker matches the
        // user's device locale (the wire format is HH:mm regardless).
        return child ?? const SizedBox.shrink();
      },
    );
    if (picked == null) return;
    final formatted = _formatTimeOfDay(picked);
    setState(() {
      if (isArrival) {
        _arrival = formatted;
      } else {
        _endTime = formatted;
        _showEndTimeError =
            _arrival != null && _compareHHMM(_endTime!, _arrival!) <= 0;
      }
    });
  }

  void _save() {
    if (!_saveEnabled) {
      setState(() => _showEndTimeError = true);
      return;
    }
    final body = _isEdit ? _buildPatch() : _buildCreateBody();
    if (_isEdit && body.isEmpty) {
      // Nothing changed — close without sending.
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(body);
  }

  Map<String, dynamic> _buildCreateBody() {
    final body = <String, dynamic>{
      'name': _name.text.trim(),
      'kind': _kind == StopKind.unknown ? 'activity' : _kind.name,
    };
    final city = _city.text.trim();
    if (city.isNotEmpty) body['city'] = city;
    final address = _address.text.trim();
    if (address.isNotEmpty) body['address'] = address;
    final dur = int.tryParse(_duration.text.trim());
    if (dur != null && dur >= 0) body['duration_minutes'] = dur;
    if (_arrival != null) body['arrival_time'] = _arrival;
    var endTime = _endTime;
    if (endTime == null && _arrival != null && dur != null && dur > 0) {
      endTime = _addMinutes(_arrival!, dur);
    }
    if (endTime != null) body['end_time'] = endTime;
    final transport = _transport;
    if (transport != null && transport != TransportationKind.unknown) {
      body['transportation'] = transport.name;
    }
    final notes = _notes.text.trim();
    if (notes.isNotEmpty) body['notes'] = notes;
    return body;
  }

  Map<String, dynamic> _buildPatch() {
    final init = widget.initial!;
    final patch = <String, dynamic>{};

    final newName = _name.text.trim();
    if (newName != init.name) patch['name'] = newName;

    final newKindStr = _kind == StopKind.unknown ? 'activity' : _kind.name;
    final initKindStr =
        init.kind == StopKind.unknown ? 'activity' : init.kind.name;
    if (newKindStr != initKindStr) patch['kind'] = newKindStr;

    final newCity = _orNull(_city.text.trim());
    if (newCity != init.city) patch['city'] = newCity;

    final newAddress = _orNull(_address.text.trim());
    if (newAddress != init.address) patch['address'] = newAddress;

    final newDuration = int.tryParse(_duration.text.trim());
    if (newDuration != init.durationMinutes) {
      patch['duration_minutes'] = newDuration;
    }

    if (_arrival != init.arrivalTime) {
      patch['arrival_time'] = _arrival;
    }

    var newEnd = _endTime;
    if (newEnd == null &&
        _arrival != null &&
        newDuration != null &&
        newDuration > 0) {
      newEnd = _addMinutes(_arrival!, newDuration);
    }
    if (newEnd != init.endTime) patch['end_time'] = newEnd;

    final newTransport =
        (_transport == null || _transport == TransportationKind.unknown)
        ? null
        : _transport!.name;
    final initTransport =
        (init.transportation == null ||
            init.transportation == TransportationKind.unknown)
        ? null
        : init.transportation!.name;
    if (newTransport != initTransport) {
      patch['transportation'] = newTransport;
    }

    final newNotes = _orNull(_notes.text.trim());
    if (newNotes != init.notes) patch['notes'] = newNotes;

    return patch;
  }

  String? _orNull(String s) => s.isEmpty ? null : s;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(colors),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                $styles.insets.md,
                $styles.insets.sm,
                $styles.insets.md,
                $styles.insets.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _label('Name'),
                  _textField(
                    controller: _name,
                    autofocus: !_isEdit,
                    hint: 'Stop name',
                  ),
                  Gap($styles.insets.md),
                  _label('Type'),
                  _kindChips(),
                  Gap($styles.insets.md),
                  _label('Transport'),
                  _transportChips(),
                  Gap($styles.insets.md),
                  _label('City'),
                  _textField(controller: _city, hint: 'Optional'),
                  Gap($styles.insets.sm),
                  _label('Address'),
                  _textField(
                    controller: _address,
                    hint: 'Optional',
                    maxLines: 2,
                  ),
                  Gap($styles.insets.md),
                  Row(
                    children: [
                      Expanded(
                        child: _timeColumn(
                          label: 'Arrival',
                          value: _arrival,
                          onPick: () => _pickTime(isArrival: true),
                          onClear: () => setState(() {
                            _arrival = null;
                            _showEndTimeError = false;
                          }),
                        ),
                      ),
                      Gap($styles.insets.sm),
                      Expanded(
                        child: _timeColumn(
                          label: 'End',
                          value: _endTime,
                          onPick: () => _pickTime(isArrival: false),
                          onClear: () => setState(() {
                            _endTime = null;
                            _showEndTimeError = false;
                          }),
                        ),
                      ),
                    ],
                  ),
                  if (_showEndTimeError &&
                      _arrival != null &&
                      _endTime != null &&
                      _compareHHMM(_endTime!, _arrival!) <= 0) ...[
                    Gap($styles.insets.xs),
                    Text(
                      'End must be after arrival',
                      style: $styles.text.body.copyWith(
                        color: $styles.colors.error,
                      ),
                    ),
                  ],
                  Gap($styles.insets.md),
                  _label('Duration (min)'),
                  _textField(
                    controller: _duration,
                    hint: 'e.g. 90',
                    keyboardType: TextInputType.number,
                  ),
                  Gap($styles.insets.md),
                  _label('Notes'),
                  _textField(
                    controller: _notes,
                    hint: 'Optional',
                    maxLines: 3,
                  ),
                  if (_isEdit) _readonlyMeta(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: $styles.insets.sm,
        vertical: $styles.insets.xs,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.black.withValues(alpha: 0.4)),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: $styles.text.body.copyWith(color: colors.greyMedium),
            ),
          ),
          Expanded(
            child: Text(
              _isEdit ? 'Edit stop' : 'Add stop',
              textAlign: TextAlign.center,
              style: $styles.text.bodyBold.copyWith(color: colors.offWhite),
            ),
          ),
          TextButton(
            onPressed: _saveEnabled ? _save : null,
            child: Text(
              'Save',
              style: $styles.text.bodyBold.copyWith(
                color: _saveEnabled ? colors.accent1 : colors.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: $styles.insets.xs),
      child: Text(
        text,
        style: $styles.text.body.copyWith(color: $styles.colors.greyMedium),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    bool autofocus = false,
    TextInputType? keyboardType,
  }) {
    final colors = $styles.colors;
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: $styles.text.body.copyWith(color: colors.offWhite),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: $styles.text.body.copyWith(color: colors.caption),
        contentPadding: EdgeInsets.symmetric(
          horizontal: $styles.insets.sm,
          vertical: $styles.insets.xs,
        ),
        filled: true,
        fillColor: colors.black.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular($styles.corners.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _kindChips() {
    final selectableKinds = StopKind.values
        .where((k) => k != StopKind.unknown)
        .toList(growable: false);
    return Wrap(
      spacing: $styles.insets.xs,
      runSpacing: $styles.insets.xs,
      children: [
        for (final k in selectableKinds)
          _Chip(
            label: _kindLabel(k),
            icon: _stopKindIcon(k),
            selected: _kind == k,
            onTap: () => setState(() => _kind = k),
          ),
      ],
    );
  }

  Widget _transportChips() {
    final options = TransportationKind.values
        .where((t) => t != TransportationKind.unknown)
        .toList(growable: false);
    return Wrap(
      spacing: $styles.insets.xs,
      runSpacing: $styles.insets.xs,
      children: [
        _Chip(
          label: 'None',
          icon: Icons.do_not_disturb_alt,
          selected: _transport == null,
          onTap: () => setState(() => _transport = null),
        ),
        for (final t in options)
          _Chip(
            label: _transportLabel(t),
            icon: _transportIcon(t),
            selected: _transport == t,
            onTap: () => setState(() => _transport = t),
          ),
      ],
    );
  }

  Widget _timeColumn({
    required String label,
    required String? value,
    required VoidCallback onPick,
    required VoidCallback onClear,
  }) {
    final colors = $styles.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.greyMedium),
                  padding: EdgeInsets.symmetric(
                    horizontal: $styles.insets.sm,
                    vertical: $styles.insets.xs,
                  ),
                ),
                child: Text(
                  value ?? '—',
                  style: $styles.text.body.copyWith(
                    color: value != null ? colors.offWhite : colors.caption,
                  ),
                ),
              ),
            ),
            if (value != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  color: colors.caption,
                  size: 18,
                ),
                onPressed: onClear,
              ),
          ],
        ),
      ],
    );
  }

  Widget _readonlyMeta() {
    final init = widget.initial!;
    final entries = <Widget>[];
    if (init.lat != null && init.lng != null) {
      entries.add(
        Text(
          'Lat ${init.lat!.toStringAsFixed(5)}, Lng ${init.lng!.toStringAsFixed(5)}',
          style: $styles.text.body.copyWith(color: $styles.colors.caption),
        ),
      );
    }
    if (entries.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: $styles.insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = $styles.colors;
    final fg = selected ? colors.greyStrong : colors.offWhite;
    final bg = selected ? colors.accent1 : colors.black.withValues(alpha: 0.4);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular($styles.corners.card),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: $styles.insets.sm,
          vertical: $styles.insets.xs,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular($styles.corners.card),
          border: Border.all(
            color: selected ? colors.accent1 : colors.greyMedium,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            Gap($styles.insets.xs),
            Text(label, style: $styles.text.body.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}

String _kindLabel(StopKind k) {
  switch (k) {
    case StopKind.sight:
      return 'Sight';
    case StopKind.beach:
      return 'Beach';
    case StopKind.hike:
      return 'Hike';
    case StopKind.meal:
      return 'Meal';
    case StopKind.stay:
      return 'Stay';
    case StopKind.transport:
      return 'Transport';
    case StopKind.activity:
      return 'Activity';
    case StopKind.unknown:
      return 'Activity';
  }
}

String _transportLabel(TransportationKind t) {
  switch (t) {
    case TransportationKind.walk:
      return 'Walk';
    case TransportationKind.taxi:
      return 'Taxi';
    case TransportationKind.tram:
      return 'Tram';
    case TransportationKind.bus:
      return 'Bus';
    case TransportationKind.car:
      return 'Car';
    case TransportationKind.other:
      return 'Other';
    case TransportationKind.unknown:
      return 'Other';
  }
}

IconData _stopKindIcon(StopKind k) {
  switch (k) {
    case StopKind.sight:
      return Icons.place;
    case StopKind.beach:
      return Icons.beach_access;
    case StopKind.hike:
      return Icons.terrain;
    case StopKind.meal:
      return Icons.restaurant;
    case StopKind.stay:
      return Icons.hotel;
    case StopKind.transport:
      return Icons.directions_bus;
    case StopKind.activity:
      return Icons.local_activity;
    case StopKind.unknown:
      return Icons.help_outline;
  }
}

IconData _transportIcon(TransportationKind t) {
  switch (t) {
    case TransportationKind.walk:
      return Icons.directions_walk;
    case TransportationKind.taxi:
      return Icons.local_taxi;
    case TransportationKind.tram:
      return Icons.tram;
    case TransportationKind.bus:
      return Icons.directions_bus;
    case TransportationKind.car:
      return Icons.directions_car;
    case TransportationKind.other:
      return Icons.commute;
    case TransportationKind.unknown:
      return Icons.help_outline;
  }
}

TimeOfDay? _parseHHMM(String s) {
  final parts = s.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return TimeOfDay(hour: h, minute: m);
}

String _formatTimeOfDay(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

int _compareHHMM(String a, String b) {
  final ta = _parseHHMM(a);
  final tb = _parseHHMM(b);
  if (ta == null || tb == null) return 0;
  return (ta.hour * 60 + ta.minute) - (tb.hour * 60 + tb.minute);
}

String? _addMinutes(String hhmm, int minutes) {
  final t = _parseHHMM(hhmm);
  if (t == null) return null;
  final total = t.hour * 60 + t.minute + minutes;
  if (total < 0 || total >= 24 * 60) return null;
  final h = (total ~/ 60).toString().padLeft(2, '0');
  final m = (total % 60).toString().padLeft(2, '0');
  return '$h:$m';
}
