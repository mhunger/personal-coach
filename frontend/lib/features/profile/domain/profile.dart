/// Pure domain model for the user profile. No serialization logic here.
class Profile {
  final int? id;
  final DateTime? dateOfBirth;
  final int? heightCm;
  final double? weightKg;
  final double? bodyFatPct;
  final String? primaryGoal;
  final double? targetWeightKg;
  final String? injuries;
  final String? dietaryRestrictions;
  final String? workHoursDescription;
  final GymAccess gymAccess;
  final String? equipment;
  final int? trainingDaysPerWeek;
  final int? sessionMinutesTarget;

  const Profile({
    this.id,
    this.dateOfBirth,
    this.heightCm,
    this.weightKg,
    this.bodyFatPct,
    this.primaryGoal,
    this.targetWeightKg,
    this.injuries,
    this.dietaryRestrictions,
    this.workHoursDescription,
    this.gymAccess = GymAccess.home,
    this.equipment,
    this.trainingDaysPerWeek,
    this.sessionMinutesTarget,
  });
}

enum GymAccess { home, fullGym, both }
