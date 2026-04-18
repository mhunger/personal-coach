package com.personalcoach.training;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TrainingPlanRepository extends JpaRepository<TrainingPlan, Long> {

    List<TrainingPlan> findByIsoWeekOrderByGeneratedAtDesc(String isoWeek);
}
