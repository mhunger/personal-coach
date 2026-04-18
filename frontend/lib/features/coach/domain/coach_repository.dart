import 'component.dart';

abstract class CoachRepository {
  Future<List<Component>> fetchSuggestions({String context = 'today'});
}
