package com.personalcoach.coach;

import java.time.Instant;
import java.util.List;
import java.util.Map;

public record MessageDto(
        Long id,
        Long conversationId,
        CoachMessageRole role,
        List<Map<String, Object>> components,
        Instant createdAt
) {
}
