package com.personalcoach.coach;

import java.util.List;
import java.util.Map;

/**
 * A stream of rendered components published by the coach. The backend is
 * deliberately schema-agnostic here — the sidecar and frontend are the
 * authoritative contract on component shapes (see coach-sidecar/components.py
 * and frontend/lib/features/coach). We just shuttle the JSON through.
 */
public record ComponentStream(List<Map<String, Object>> components) {
}
