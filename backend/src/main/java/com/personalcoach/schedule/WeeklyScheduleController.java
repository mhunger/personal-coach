package com.personalcoach.schedule;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/schedule")
public class WeeklyScheduleController {

    private final WeeklyScheduleService service;

    public WeeklyScheduleController(WeeklyScheduleService service) {
        this.service = service;
    }

    @GetMapping
    public WeeklyScheduleDto get(@RequestParam("week") String week) {
        return service.getOrEmpty(week);
    }

    @PutMapping
    public WeeklyScheduleDto put(@RequestParam("week") String week,
                                 @RequestBody WeeklyScheduleDto dto) {
        return service.upsert(week, dto);
    }
}
