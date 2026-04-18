package com.personalcoach.profile;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
class ProfileSeeder implements CommandLineRunner {

    private final UserProfileRepository repo;

    ProfileSeeder(UserProfileRepository repo) {
        this.repo = repo;
    }

    @Override
    public void run(String... args) {
        if (repo.count() > 0) {
            return;
        }
        UserProfile seed = UserProfile.builder()
                .gymAccess(GymAccess.HOME)
                .primaryGoal("General fitness and stress regulation")
                .trainingDaysPerWeek(4)
                .sessionMinutesTarget(45)
                .build();
        repo.save(seed);
    }
}
