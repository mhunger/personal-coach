package com.personalcoach.training;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class TrainingPlanService {

    private final TrainingPlanRepository plans;
    private final TrainingSessionRepository sessions;

    public TrainingPlanService(TrainingPlanRepository plans,
                               TrainingSessionRepository sessions) {
        this.plans = plans;
        this.sessions = sessions;
    }

    public TrainingPlanDto save(SavePlanRequest request) {
        TrainingPlan plan = plans.save(TrainingPlan.builder()
                .isoWeek(request.isoWeek())
                .rationale(request.rationale())
                .build());

        List<TrainingSession> saved = request.sessions().stream()
                .map(s -> TrainingSession.builder()
                        .planId(plan.getId())
                        .dayOfWeek(s.dayOfWeek())
                        .plannedStart(s.plannedStart())
                        .durationMinutes(s.durationMinutes())
                        .focus(s.focus())
                        .exercises(s.exercises() == null ? List.of() : s.exercises())
                        .build())
                .map(sessions::save)
                .toList();

        return toDto(plan, saved);
    }

    @Transactional(readOnly = true)
    public List<TrainingPlanDto> forWeek(String isoWeek) {
        return plans.findByIsoWeekOrderByGeneratedAtDesc(isoWeek).stream()
                .map(plan -> toDto(plan, sessions.findByPlanIdOrderByIdAsc(plan.getId())))
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<TrainingPlanDto> byId(Long id) {
        return plans.findById(id)
                .map(plan -> toDto(plan, sessions.findByPlanIdOrderByIdAsc(plan.getId())));
    }

    private TrainingPlanDto toDto(TrainingPlan p, List<TrainingSession> entities) {
        return new TrainingPlanDto(
                p.getId(),
                p.getIsoWeek(),
                p.getGeneratedAt(),
                p.getRationale(),
                entities.stream()
                        .map(s -> new TrainingSessionDto(
                                s.getId(),
                                s.getDayOfWeek(),
                                s.getPlannedStart(),
                                s.getDurationMinutes(),
                                s.getFocus(),
                                s.getExercises() == null ? List.of() : s.getExercises()
                        ))
                        .toList()
        );
    }
}
