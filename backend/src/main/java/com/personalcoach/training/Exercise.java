package com.personalcoach.training;

public record Exercise(
        String name,
        Integer sets,
        String reps,
        String weight,
        String notes
) {
}
