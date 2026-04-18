package com.personalcoach.schedule;

import java.time.DayOfWeek;
import java.time.LocalTime;

public record BusyBlock(
        DayOfWeek day,
        LocalTime startTime,
        LocalTime endTime,
        String label
) {
}
