import 'chat_result.dart';
import 'coach_turn.dart';
import 'component.dart';

abstract class CoachRepository {
  Future<List<Component>> fetchSuggestions({String context = 'today'});

  Future<ChatResult> sendMessage({int? conversationId, required String message});

  Future<List<CoachTurn>> fetchHistory(int conversationId);
}
