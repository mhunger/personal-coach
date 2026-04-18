package com.personalcoach.training;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TrainingSessionRepository extends JpaRepository<TrainingSession, Long> {

    List<TrainingSession> findByPlanIdOrderByIdAsc(Long planId);
}
