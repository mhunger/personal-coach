package com.personalcoach.coach;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

/**
 * Orchestrates a chat turn: load or create the conversation, persist the
 * user's message, call the sidecar with history, persist the coach's
 * published components, and return them to the caller.
 */
@Service
@Transactional
public class CoachService {

    private final CoachConversationRepository conversations;
    private final CoachMessageRepository messages;
    private final CoachSidecarClient sidecar;

    public CoachService(CoachConversationRepository conversations,
                        CoachMessageRepository messages,
                        CoachSidecarClient sidecar) {
        this.conversations = conversations;
        this.messages = messages;
        this.sidecar = sidecar;
    }

    public ChatResponse chat(ChatRequest request) {
        CoachConversation conversation = request.conversationId() == null
                ? conversations.save(new CoachConversation())
                : conversations.findById(request.conversationId())
                        .orElseThrow(() -> new IllegalArgumentException(
                                "Unknown conversation: " + request.conversationId()));

        List<CoachMessage> history = messages.findByConversationIdOrderByIdAsc(conversation.getId());

        // Persist the user's message up front so history is complete even if the
        // sidecar call fails.
        List<Map<String, Object>> userComponents = List.of(Map.of(
                "type", "TextBlock",
                "content", request.message()
        ));
        messages.save(CoachMessage.builder()
                .conversationId(conversation.getId())
                .role(CoachMessageRole.USER)
                .components(userComponents)
                .build());

        List<Map<String, Object>> wireHistory = toWireHistory(history);
        ComponentStream stream = sidecar.chat(request.message(), wireHistory);

        messages.save(CoachMessage.builder()
                .conversationId(conversation.getId())
                .role(CoachMessageRole.COACH)
                .components(stream.components())
                .build());

        return new ChatResponse(conversation.getId(), stream.components());
    }

    @Transactional(readOnly = true)
    public List<MessageDto> history(Long conversationId) {
        return messages.findByConversationIdOrderByIdAsc(conversationId).stream()
                .map(this::toDto)
                .toList();
    }

    private List<Map<String, Object>> toWireHistory(List<CoachMessage> msgs) {
        return msgs.stream()
                .<Map<String, Object>>map(m -> Map.of(
                        "role", m.getRole().name().toLowerCase(),
                        "components", (Object) m.getComponents()
                ))
                .toList();
    }

    private MessageDto toDto(CoachMessage m) {
        return new MessageDto(
                m.getId(),
                m.getConversationId(),
                m.getRole(),
                m.getComponents(),
                m.getCreatedAt()
        );
    }
}
