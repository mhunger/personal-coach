package com.personalcoach.training;

import java.time.Instant;
import java.util.List;

public record TrainingPlanDto(
        Long id,
        String isoWeek,
        Instant generatedAt,
        String rationale,
        List<TrainingSessionDto> sessions
) {
}
