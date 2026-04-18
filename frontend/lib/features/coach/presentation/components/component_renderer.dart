import 'package:flutter/material.dart';

import '../../domain/component.dart';
import 'recipe_card_widget.dart';
import 'suggestion_card_widget.dart';
import 'text_block_widget.dart';
import 'training_session_card_widget.dart';
import 'unknown_component_widget.dart';

/// Dispatches a [Component] to the widget that renders it. The sealed
/// switch keeps this exhaustive — a missing branch is a compile error.
class ComponentRenderer extends StatelessWidget {
  final Component component;

  const ComponentRenderer({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return switch (component) {
      TextBlockComponent c => TextBlockWidget(component: c),
      SuggestionCardComponent c => SuggestionCardWidget(component: c),
      TrainingSessionCardComponent c => TrainingSessionCardWidget(component: c),
      RecipeCardComponent c => RecipeCardWidget(component: c),
      UnknownComponent c => UnknownComponentWidget(component: c),
    };
  }
}
