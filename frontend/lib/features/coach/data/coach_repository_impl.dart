import '../../../core/api/api_client.dart';
import '../domain/chat_result.dart';
import '../domain/coach_repository.dart';
import '../domain/coach_turn.dart';
import '../domain/component.dart';
import 'component_mapper.dart';

class CoachRepositoryImpl implements CoachRepository {
  final ApiClient api;

  CoachRepositoryImpl(this.api);

  @override
  Future<List<Component>> fetchSuggestions({String context = 'today'}) async {
    final json = await api.get('/api/coach/suggestions', query: {'context': context})
        as Map<String, dynamic>;
    return _parseComponents(json['components']);
  }

  @override
  Future<ChatResult> sendMessage({int? conversationId, required String message}) async {
    final json = await api.post(
      '/api/coach/chat',
      body: {
        if (conversationId != null) 'conversationId': conversationId,
        'message': message,
      },
    ) as Map<String, dynamic>;
    return ChatResult(
      conversationId: (json['conversationId'] as num).toInt(),
      components: _parseComponents(json['components']),
    );
  }

  @override
  Future<List<CoachTurn>> fetchHistory(int conversationId) async {
    final raw = await api.get('/api/coach/conversations/$conversationId')
        as List<dynamic>;
    return raw.map((m) {
      final map = m as Map<String, dynamic>;
      final role = (map['role'] as String).toUpperCase() == 'USER'
          ? TurnRole.user
          : TurnRole.coach;
      final createdAt = map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null;
      return CoachTurn(
        role: role,
        components: _parseComponents(map['components']),
        createdAt: createdAt,
      );
    }).toList();
  }

  List<Component> _parseComponents(Object? raw) {
    final list = (raw as List<dynamic>? ?? []);
    return list
        .map((c) => ComponentMapper.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
