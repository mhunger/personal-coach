import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../shared/widgets/paper_card.dart';
import '../../domain/component.dart';

/// A single workout — header row in small caps, exercises in a tabular
/// monospace grid, italic notes footer.
class TrainingSessionCardWidget extends StatelessWidget {
  final TrainingSessionCardComponent component;

  const TrainingSessionCardWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— ${component.dayOfWeek.toUpperCase()} —',
            style: AppTypography.sectionTag,
          ),
          const SizedBox(height: 8),
          Text(component.focus, style: AppTypography.headline),
          const SizedBox(height: 6),
          Row(
            children: [
              if (component.plannedStart != null)
                Text(component.plannedStart!, style: AppTypography.numericMedium),
              if (component.plannedStart != null) const SizedBox(width: 14),
              Text('${component.durationMinutes} min',
                  style: AppTypography.numericMedium),
            ],
          ),
          if (component.exercises.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.ruleGray),
            const SizedBox(height: 10),
            for (final ex in component.exercises) _ExerciseRow(exercise: ex),
          ],
          if (component.notes != null && component.notes!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(component.notes!, style: AppTypography.coachVoice),
          ],
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final ExerciseEntry exercise;

  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final rightParts = <String>[
      if (exercise.sets != null) '${exercise.sets} sets',
      if (exercise.reps != null) '× ${exercise.reps}',
      if (exercise.weight != null) exercise.weight!,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(exercise.name, style: AppTypography.body),
          ),
          const SizedBox(width: 12),
          Text(
            rightParts.join('  '),
            style: AppTypography.numericMedium,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
