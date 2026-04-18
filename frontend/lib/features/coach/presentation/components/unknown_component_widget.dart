import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../shared/widgets/paper_card.dart';
import '../../domain/component.dart';

/// Shown when the sidecar published a component type the frontend doesn't
/// render yet. Deliberately visible rather than silently dropped — the gap
/// is a TODO the user and I should notice and close.
class UnknownComponentWidget extends StatelessWidget {
  final UnknownComponent component;

  const UnknownComponentWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      color: AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MISSING RENDERER', style: AppTypography.metaTag),
          const SizedBox(height: 10),
          Text('Type: ${component.type}', style: AppTypography.headline),
          const SizedBox(height: 10),
          Text(
            'Add a widget in features/coach/presentation/components/ '
            'and wire it into ComponentRenderer.',
            style: AppTypography.body.copyWith(color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}
