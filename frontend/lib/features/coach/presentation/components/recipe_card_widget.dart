import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../shared/widgets/paper_card.dart';
import '../../domain/component.dart';

/// A cookbook plate — title in Fraunces display, metadata row in
/// small caps + mono, two-column ingredients and method.
class RecipeCardWidget extends StatelessWidget {
  final RecipeCardComponent component;

  const RecipeCardWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (component.imageUrl != null && component.imageUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Image.network(
                component.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.ruleGray),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(component.title, style: AppTypography.title),
                const SizedBox(height: 10),
                _MetaRow(component: component),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth >= 420;
                  final ingredients = _Ingredients(
                    ingredients: component.ingredients,
                  );
                  final method = _Method(method: component.method);
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: ingredients),
                        const SizedBox(width: 28),
                        Expanded(flex: 6, child: method),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ingredients, const SizedBox(height: 20), method],
                  );
                }),
                if (component.notes != null && component.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(component.notes!, style: AppTypography.coachVoice),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final RecipeCardComponent component;

  const _MetaRow({required this.component});

  @override
  Widget build(BuildContext context) {
    String fmt(String label, String value) =>
        '${label.toUpperCase()}  $value';
    final items = [
      fmt('serves', component.servings.toString()),
      fmt('prep', '${component.prepMinutes} min'),
      fmt('cook', '${component.cookMinutes} min'),
    ];
    return Wrap(
      spacing: 20,
      runSpacing: 4,
      children: items
          .map((t) => Text(
                t,
                style: AppTypography.metaTag.copyWith(color: AppColors.ink),
              ))
          .toList(),
    );
  }
}

class _Ingredients extends StatelessWidget {
  final List<IngredientEntry> ingredients;

  const _Ingredients({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('— INGREDIENTS —', style: AppTypography.sectionTag),
        const SizedBox(height: 10),
        for (final ing in ingredients)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(
                  width: 68,
                  child: Text(ing.quantity, style: AppTypography.numericMedium),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(ing.item, style: AppTypography.body)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Method extends StatelessWidget {
  final List<String> method;

  const _Method({required this.method});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('— METHOD —', style: AppTypography.sectionTag),
        const SizedBox(height: 10),
        for (var i = 0; i < method.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text('${i + 1}.',
                      style: AppTypography.numericMedium),
                ),
                Expanded(child: Text(method[i], style: AppTypography.body)),
              ],
            ),
          ),
      ],
    );
  }
}
