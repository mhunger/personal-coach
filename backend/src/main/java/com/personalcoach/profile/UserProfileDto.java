package com.personalcoach.profile;

import java.math.BigDecimal;
import java.time.LocalDate;

public record UserProfileDto(
        Long id,
        LocalDate dateOfBirth,
        Integer heightCm,
        BigDecimal weightKg,
        BigDecimal bodyFatPct,
        String primaryGoal,
        BigDecimal targetWeightKg,
        String injuries,
        String dietaryRestrictions,
        String workHoursDescription,
        GymAccess gymAccess,
        String equipment,
        Integer trainingDaysPerWeek,
        Integer sessionMinutesTarget
) {
}
