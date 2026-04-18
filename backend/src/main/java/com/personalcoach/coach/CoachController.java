package com.personalcoach.coach;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/coach")
public class CoachController {

    private final CoachSidecarClient sidecar;

    public CoachController(CoachSidecarClient sidecar) {
        this.sidecar = sidecar;
    }

    @GetMapping("/suggestions")
    public ComponentStream suggestions(
            @RequestParam(name = "context", defaultValue = "today") String context) {
        return sidecar.suggestions(context);
    }
}
