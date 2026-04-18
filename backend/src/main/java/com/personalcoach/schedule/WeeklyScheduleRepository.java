package com.personalcoach.schedule;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WeeklyScheduleRepository extends JpaRepository<WeeklySchedule, Long> {

    Optional<WeeklySchedule> findByIsoWeek(String isoWeek);
}
