package com.personalcoach.profile;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UserProfileService {

    private final UserProfileRepository repo;

    public UserProfileService(UserProfileRepository repo) {
        this.repo = repo;
    }

    @Transactional(readOnly = true)
    public UserProfileDto get() {
        UserProfile p = repo.findAll().stream().findFirst()
                .orElseThrow(() -> new IllegalStateException("Profile not seeded yet"));
        return toDto(p);
    }

    public UserProfileDto update(UserProfileDto dto) {
        UserProfile p = repo.findAll().stream().findFirst()
                .orElseGet(UserProfile::new);
        apply(p, dto);
        return toDto(repo.save(p));
    }

    private void apply(UserProfile p, UserProfileDto d) {
        p.setDateOfBirth(d.dateOfBirth());
        p.setHeightCm(d.heightCm());
        p.setWeightKg(d.weightKg());
        p.setBodyFatPct(d.bodyFatPct());
        p.setPrimaryGoal(d.primaryGoal());
        p.setTargetWeightKg(d.targetWeightKg());
        p.setInjuries(d.injuries());
        p.setDietaryRestrictions(d.dietaryRestrictions());
        p.setWorkHoursDescription(d.workHoursDescription());
        p.setGymAccess(d.gymAccess() != null ? d.gymAccess() : GymAccess.HOME);
        p.setEquipment(d.equipment());
        p.setTrainingDaysPerWeek(d.trainingDaysPerWeek());
        p.setSessionMinutesTarget(d.sessionMinutesTarget());
    }

    private UserProfileDto toDto(UserProfile p) {
        return new UserProfileDto(
                p.getId(),
                p.getDateOfBirth(),
                p.getHeightCm(),
                p.getWeightKg(),
                p.getBodyFatPct(),
                p.getPrimaryGoal(),
                p.getTargetWeightKg(),
                p.getInjuries(),
                p.getDietaryRestrictions(),
                p.getWorkHoursDescription(),
                p.getGymAccess(),
                p.getEquipment(),
                p.getTrainingDaysPerWeek(),
                p.getSessionMinutesTarget()
        );
    }
}
