import '../domain/coach_turn.dart';

class ConversationState {
  final int? conversationId;
  final List<CoachTurn> turns;
  final bool isSending;
  final String? error;

  const ConversationState({
    this.conversationId,
    this.turns = const [],
    this.isSending = false,
    this.error,
  });

  const ConversationState.initial() : this();

  ConversationState copyWith({
    int? conversationId,
    List<CoachTurn>? turns,
    bool? isSending,
    String? error,
  }) {
    return ConversationState(
      conversationId: conversationId ?? this.conversationId,
      turns: turns ?? this.turns,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}
