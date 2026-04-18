package com.personalcoach.coach;

import java.util.List;
import java.util.Map;

public record ChatResponse(Long conversationId, List<Map<String, Object>> components) {
}
