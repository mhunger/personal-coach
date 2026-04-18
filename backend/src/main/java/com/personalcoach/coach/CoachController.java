package com.personalcoach.coach;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/coach")
public class CoachController {

    private final CoachSidecarClient sidecar;
    private final CoachService service;

    public CoachController(CoachSidecarClient sidecar, CoachService service) {
        this.sidecar = sidecar;
        this.service = service;
    }

    @GetMapping("/suggestions")
    public ComponentStream suggestions(
            @RequestParam(name = "context", defaultValue = "today") String context) {
        return sidecar.suggestions(context);
    }

    @PostMapping("/chat")
    public ChatResponse chat(@RequestBody ChatRequest request) {
        return service.chat(request);
    }

    @GetMapping("/conversations/{id}")
    public List<MessageDto> history(@PathVariable("id") Long id) {
        return service.history(id);
    }
}
