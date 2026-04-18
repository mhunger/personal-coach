import '../domain/profile.dart';

class ProfileMapper {
  const ProfileMapper._();

  static Profile fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as int?,
      dateOfBirth: _parseDate(json['dateOfBirth'] as String?),
      heightCm: json['heightCm'] as int?,
      weightKg: _toDouble(json['weightKg']),
      bodyFatPct: _toDouble(json['bodyFatPct']),
      primaryGoal: json['primaryGoal'] as String?,
      targetWeightKg: _toDouble(json['targetWeightKg']),
      injuries: json['injuries'] as String?,
      dietaryRestrictions: json['dietaryRestrictions'] as String?,
      workHoursDescription: json['workHoursDescription'] as String?,
      gymAccess: _gymAccess(json['gymAccess'] as String?),
      equipment: json['equipment'] as String?,
      trainingDaysPerWeek: json['trainingDaysPerWeek'] as int?,
      sessionMinutesTarget: json['sessionMinutesTarget'] as int?,
    );
  }

  static DateTime? _parseDate(String? s) => s == null ? null : DateTime.parse(s);

  static double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static GymAccess _gymAccess(String? s) {
    switch (s) {
      case 'FULL_GYM':
        return GymAccess.fullGym;
      case 'BOTH':
        return GymAccess.both;
      case 'HOME':
      default:
        return GymAccess.home;
    }
  }
}
