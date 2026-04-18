package com.personalcoach.schedule;

import java.util.List;

public record WeeklyScheduleDto(
        Long id,
        String isoWeek,
        String notes,
        List<BusyBlock> busyBlocks
) {
}
