package com.personalcoach.profile;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

@Entity
@Table(name = "user_profile")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Column(name = "height_cm")
    private Integer heightCm;

    @Column(name = "weight_kg")
    private BigDecimal weightKg;

    @Column(name = "body_fat_pct")
    private BigDecimal bodyFatPct;

    @Column(name = "primary_goal")
    private String primaryGoal;

    @Column(name = "target_weight_kg")
    private BigDecimal targetWeightKg;

    @Column(columnDefinition = "TEXT")
    private String injuries;

    @Column(name = "dietary_restrictions", columnDefinition = "TEXT")
    private String dietaryRestrictions;

    @Column(name = "work_hours_description", columnDefinition = "TEXT")
    private String workHoursDescription;

    @Enumerated(EnumType.STRING)
    @Column(name = "gym_access", nullable = false, length = 32)
    private GymAccess gymAccess;

    @Column(columnDefinition = "TEXT")
    private String equipment;

    @Column(name = "training_days_per_week")
    private Integer trainingDaysPerWeek;

    @Column(name = "session_minutes_target")
    private Integer sessionMinutesTarget;

    @Column(name = "created_at", insertable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", insertable = false, updatable = false)
    private Instant updatedAt;
}
