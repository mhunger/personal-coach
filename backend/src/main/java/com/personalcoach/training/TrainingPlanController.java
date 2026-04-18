package com.personalcoach.training;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/training-plans")
public class TrainingPlanController {

    private final TrainingPlanService service;

    public TrainingPlanController(TrainingPlanService service) {
        this.service = service;
    }

    /**
     * Persist a plan composed by the coach agent. Called by the sidecar
     * from the `save_training_plan` tool.
     */
    @PostMapping("/generate")
    public TrainingPlanDto save(@RequestBody SavePlanRequest request) {
        return service.save(request);
    }

    @GetMapping
    public List<TrainingPlanDto> forWeek(@RequestParam("week") String week) {
        return service.forWeek(week);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TrainingPlanDto> byId(@PathVariable("id") Long id) {
        return service.byId(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
