package com.personalcoach.training;

import java.util.List;

/**
 * Payload the sidecar sends when the agent invokes `save_training_plan`.
 * Sessions come fully composed by the agent — this endpoint just persists.
 */
public record SavePlanRequest(
        String isoWeek,
        String rationale,
        List<TrainingSessionDto> sessions
) {
}
