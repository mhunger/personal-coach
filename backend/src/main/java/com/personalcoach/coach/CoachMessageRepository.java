package com.personalcoach.coach;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CoachMessageRepository extends JpaRepository<CoachMessage, Long> {

    List<CoachMessage> findByConversationIdOrderByIdAsc(Long conversationId);
}
