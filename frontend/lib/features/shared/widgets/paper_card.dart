import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import 'corner_mark.dart';

/// The standard card surface across the edition: cream paper inset, thin
/// rule-gray border, and the signature oxblood corner mark in the upper-right.
///
/// Used by every component type (SuggestionCard, RecipeCard,
/// TrainingSessionCard, …). Kept deliberately flat — no shadow — so the
/// aesthetic reads as printed rather than digital.
class PaperCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool showCornerMark;

  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 22, 24, 24),
    this.color,
    this.showCornerMark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.cardInset,
        border: Border.all(color: AppColors.ruleGray, width: 1),
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          if (showCornerMark)
            const Positioned(
              top: 6,
              right: 6,
              child: CornerMark(size: 8),
            ),
        ],
      ),
    );
  }
}
