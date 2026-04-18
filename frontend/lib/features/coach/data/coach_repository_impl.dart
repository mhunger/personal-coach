import '../../../core/api/api_client.dart';
import '../domain/coach_repository.dart';
import '../domain/component.dart';
import 'component_mapper.dart';

class CoachRepositoryImpl implements CoachRepository {
  final ApiClient api;

  CoachRepositoryImpl(this.api);

  @override
  Future<List<Component>> fetchSuggestions({String context = 'today'}) async {
    final json = await api.get('/api/coach/suggestions', query: {'context': context})
        as Map<String, dynamic>;
    final rawComponents = (json['components'] as List<dynamic>? ?? []);
    return rawComponents
        .map((raw) => ComponentMapper.fromJson(raw as Map<String, dynamic>))
        .toList();
  }
}
