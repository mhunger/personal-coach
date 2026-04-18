package com.personalcoach.training;

import java.time.LocalTime;
import java.util.List;

public record TrainingSessionDto(
        Long id,
        String dayOfWeek,
        LocalTime plannedStart,
        Integer durationMinutes,
        String focus,
        List<Exercise> exercises
) {
}
