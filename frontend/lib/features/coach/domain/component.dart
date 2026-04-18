/// Sealed hierarchy for every component type the coach can publish.
///
/// Each concrete component mirrors a Pydantic model in the Python sidecar
/// (see coach-sidecar/src/coach/components.py). New types must be added in
/// three places in lockstep: here, the JSON mapper, and a matching widget.
sealed class Component {
  const Component();
}

class TextBlockComponent extends Component {
  final String content;

  const TextBlockComponent({required this.content});
}

class SuggestionCardComponent extends Component {
  final String tag;
  final String heading;
  final String body;
  final String? actionLabel;
  final String? actionRef;

  const SuggestionCardComponent({
    required this.tag,
    required this.heading,
    required this.body,
    this.actionLabel,
    this.actionRef,
  });
}

class TrainingSessionCardComponent extends Component {
  final String dayOfWeek;
  final String? plannedStart;
  final int durationMinutes;
  final String focus;
  final List<ExerciseEntry> exercises;
  final String? notes;

  const TrainingSessionCardComponent({
    required this.dayOfWeek,
    this.plannedStart,
    required this.durationMinutes,
    required this.focus,
    this.exercises = const [],
    this.notes,
  });
}

class ExerciseEntry {
  final String name;
  final int? sets;
  final String? reps;
  final String? weight;
  final String? notes;

  const ExerciseEntry({
    required this.name,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
  });
}

class RecipeCardComponent extends Component {
  final String title;
  final String? imageUrl;
  final int servings;
  final int prepMinutes;
  final int cookMinutes;
  final List<IngredientEntry> ingredients;
  final List<String> method;
  final String? notes;

  const RecipeCardComponent({
    required this.title,
    this.imageUrl,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    this.ingredients = const [],
    this.method = const [],
    this.notes,
  });
}

class IngredientEntry {
  final String quantity;
  final String item;

  const IngredientEntry({required this.quantity, required this.item});
}

/// Fallback used when the sidecar publishes a component type the frontend
/// hasn't learned to render yet. We don't drop them — we show a diagnostic
/// block so the gap is visible and easy to close.
class UnknownComponent extends Component {
  final String type;
  final Map<String, dynamic> raw;

  const UnknownComponent({required this.type, required this.raw});
}
