import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_providers.dart';
import '../data/coach_repository_impl.dart';
import '../domain/coach_repository.dart';
import '../domain/coach_turn.dart';
import '../domain/component.dart';
import 'conversation_state.dart';

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => CoachRepositoryImpl(ref.watch(apiClientProvider)),
);

final todaySuggestionsProvider = FutureProvider<List<Component>>(
  (ref) => ref.watch(coachRepositoryProvider).fetchSuggestions(context: 'today'),
);

/// Conversation state holder — one active conversation at a time (v1).
/// Chat input drives this; turns render in order in the EditionRail.
final conversationNotifierProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>(
  (ref) => ConversationNotifier(ref.watch(coachRepositoryProvider)),
);

class ConversationNotifier extends StateNotifier<ConversationState> {
  final CoachRepository repo;

  ConversationNotifier(this.repo) : super(const ConversationState.initial());

  Future<void> send(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final optimistic = CoachTurn(
      role: TurnRole.user,
      components: [TextBlockComponent(content: trimmed)],
    );
    state = state.copyWith(
      turns: [...state.turns, optimistic],
      isSending: true,
      error: null,
    );

    try {
      final result = await repo.sendMessage(
        conversationId: state.conversationId,
        message: trimmed,
      );
      state = state.copyWith(
        conversationId: result.conversationId,
        turns: [
          ...state.turns,
          CoachTurn(role: TurnRole.coach, components: result.components),
        ],
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }
}
