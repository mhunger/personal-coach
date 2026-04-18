package com.personalcoach.coach;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Map;

/**
 * Thin HTTP client that forwards coach requests to the Python sidecar.
 * All Claude traffic lives in the sidecar; the backend never calls
 * Anthropic directly.
 */
@Component
public class CoachSidecarClient {

    private final RestClient http;

    public CoachSidecarClient(@Value("${coach.sidecar.base-url}") String baseUrl) {
        this.http = RestClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    public ComponentStream suggestions(String context) {
        return http.post()
                .uri("/coach/suggestions")
                .body(Map.of("context", context))
                .retrieve()
                .body(ComponentStream.class);
    }
}
