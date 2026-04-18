import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../shared/widgets/paper_card.dart';
import '../../domain/component.dart';

/// An editor's pick — tag, heading, body, optional action.
class SuggestionCardWidget extends StatelessWidget {
  final SuggestionCardComponent component;

  const SuggestionCardWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(component.tag, style: AppTypography.metaTag),
          const SizedBox(height: 10),
          Text(component.heading, style: AppTypography.headline),
          const SizedBox(height: 10),
          Text(component.body, style: AppTypography.body),
          if (component.actionLabel != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                component.actionLabel!.toUpperCase(),
                style: AppTypography.uiLabel.copyWith(
                  color: AppColors.oxblood,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
