import 'package:flutter/material.dart';

import '../../domain/component.dart';
import 'suggestion_card_widget.dart';
import 'text_block_widget.dart';
import 'unknown_component_widget.dart';

/// Dispatches a [Component] to the widget that renders it. Adding a new
/// component type means extending the sealed switch below.
class ComponentRenderer extends StatelessWidget {
  final Component component;

  const ComponentRenderer({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return switch (component) {
      TextBlockComponent c => TextBlockWidget(component: c),
      SuggestionCardComponent c => SuggestionCardWidget(component: c),
      // TrainingSessionCard + RecipeCard widgets arrive in step 9 alongside chat.
      UnknownComponent c => UnknownComponentWidget(component: c),
      _ => UnknownComponentWidget(
          component: UnknownComponent(
            type: component.runtimeType.toString(),
            raw: const {},
          ),
        ),
    };
  }
}
