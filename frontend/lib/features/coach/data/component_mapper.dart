import '../domain/component.dart';

class ComponentMapper {
  const ComponentMapper._();

  static Component fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'TextBlock':
        return TextBlockComponent(content: json['content'] as String? ?? '');
      case 'SuggestionCard':
        return SuggestionCardComponent(
          tag: json['tag'] as String? ?? '',
          heading: json['heading'] as String? ?? '',
          body: json['body'] as String? ?? '',
          actionLabel: json['actionLabel'] as String?,
          actionRef: json['actionRef'] as String?,
        );
      case 'TrainingSessionCard':
        return TrainingSessionCardComponent(
          dayOfWeek: json['dayOfWeek'] as String? ?? 'MONDAY',
          plannedStart: json['plannedStart'] as String?,
          durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
          focus: json['focus'] as String? ?? '',
          exercises: (json['exercises'] as List<dynamic>? ?? [])
              .map((e) => _exerciseFrom(e as Map<String, dynamic>))
              .toList(),
          notes: json['notes'] as String?,
        );
      case 'RecipeCard':
        return RecipeCardComponent(
          title: json['title'] as String? ?? '',
          imageUrl: json['imageUrl'] as String?,
          servings: (json['servings'] as num?)?.toInt() ?? 1,
          prepMinutes: (json['prepMinutes'] as num?)?.toInt() ?? 0,
          cookMinutes: (json['cookMinutes'] as num?)?.toInt() ?? 0,
          ingredients: (json['ingredients'] as List<dynamic>? ?? [])
              .map((e) => _ingredientFrom(e as Map<String, dynamic>))
              .toList(),
          method: (json['method'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
          notes: json['notes'] as String?,
        );
      default:
        return UnknownComponent(type: type ?? 'unknown', raw: json);
    }
  }

  static ExerciseEntry _exerciseFrom(Map<String, dynamic> j) => ExerciseEntry(
        name: j['name'] as String? ?? '',
        sets: (j['sets'] as num?)?.toInt(),
        reps: j['reps']?.toString(),
        weight: j['weight']?.toString(),
        notes: j['notes'] as String?,
      );

  static IngredientEntry _ingredientFrom(Map<String, dynamic> j) =>
      IngredientEntry(
        quantity: j['quantity']?.toString() ?? '',
        item: j['item'] as String? ?? '',
      );
}
