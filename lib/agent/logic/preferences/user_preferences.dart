/// Mirror of the backend `UserPreferences` row exposed via
/// `GET /preferences/me` and accepted by `POST /preferences`.
class UserPreferences {
  UserPreferences({
    required this.budget,
    required this.travelStyle,
    required this.food,
    required this.pace,
    required this.interests,
    required this.language,
    required this.groupType,
    required this.accommodation,
    required this.transport,
    required this.travelPersona,
  });

  final String budget;
  final List<String> travelStyle;
  final List<String> food;
  final String pace;
  final List<String> interests;
  final String language;
  final String groupType;
  final String accommodation;
  final String transport;
  final String? travelPersona;

  factory UserPreferences.defaults({String language = 'en'}) {
    return UserPreferences(
      budget: 'mid-range',
      travelStyle: const [],
      food: const [],
      pace: 'moderate',
      interests: const [],
      language: language,
      groupType: 'solo',
      accommodation: 'hotel',
      transport: 'car',
      travelPersona: null,
    );
  }

  factory UserPreferences.fromJson(Map<String, dynamic> j) {
    List<String> stringList(dynamic v) =>
        (v is List) ? v.whereType<String>().toList() : <String>[];
    return UserPreferences(
      budget: (j['budget'] as String?) ?? 'mid-range',
      travelStyle: stringList(j['travel_style']),
      food: stringList(j['food']),
      pace: (j['pace'] as String?) ?? 'moderate',
      interests: stringList(j['interests']),
      language: (j['language'] as String?) ?? 'en',
      groupType: (j['group_type'] as String?) ?? 'solo',
      accommodation: (j['accommodation'] as String?) ?? 'hotel',
      transport: (j['transport'] as String?) ?? 'car',
      travelPersona: j['travel_persona'] as String?,
    );
  }

  /// Sends `travel_persona` even when null so the backend's default
  /// (`travel_persona: str | None = None`) doesn't silently overwrite.
  /// Save callers must pass back the currently-loaded persona to preserve it.
  Map<String, dynamic> toJson() => {
        'budget': budget,
        'travel_style': travelStyle,
        'food': food,
        'pace': pace,
        'interests': interests,
        'language': language,
        'group_type': groupType,
        'accommodation': accommodation,
        'transport': transport,
        'travel_persona': travelPersona,
      };

  UserPreferences copyWith({
    String? budget,
    List<String>? travelStyle,
    List<String>? food,
    String? pace,
    List<String>? interests,
    String? language,
    String? groupType,
    String? accommodation,
    String? transport,
    String? travelPersona,
  }) {
    return UserPreferences(
      budget: budget ?? this.budget,
      travelStyle: travelStyle ?? this.travelStyle,
      food: food ?? this.food,
      pace: pace ?? this.pace,
      interests: interests ?? this.interests,
      language: language ?? this.language,
      groupType: groupType ?? this.groupType,
      accommodation: accommodation ?? this.accommodation,
      transport: transport ?? this.transport,
      travelPersona: travelPersona ?? this.travelPersona,
    );
  }
}
