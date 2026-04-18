package com.personalcoach.schedule;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class WeeklyScheduleService {

    private final WeeklyScheduleRepository repo;

    public WeeklyScheduleService(WeeklyScheduleRepository repo) {
        this.repo = repo;
    }

    @Transactional(readOnly = true)
    public WeeklyScheduleDto getOrEmpty(String isoWeek) {
        return repo.findByIsoWeek(isoWeek)
                .map(this::toDto)
                .orElse(new WeeklyScheduleDto(null, isoWeek, null, List.of()));
    }

    public WeeklyScheduleDto upsert(String isoWeek, WeeklyScheduleDto dto) {
        WeeklySchedule s = repo.findByIsoWeek(isoWeek)
                .orElseGet(() -> WeeklySchedule.builder().isoWeek(isoWeek).build());
        s.setNotes(dto.notes());
        s.setBusyBlocks(dto.busyBlocks() != null ? dto.busyBlocks() : List.of());
        return toDto(repo.save(s));
    }

    private WeeklyScheduleDto toDto(WeeklySchedule s) {
        return new WeeklyScheduleDto(
                s.getId(),
                s.getIsoWeek(),
                s.getNotes(),
                s.getBusyBlocks() != null ? s.getBusyBlocks() : List.of()
        );
    }
}
