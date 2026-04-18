import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/paper_grain.dart';
import '../../coach/presentation/edition_rail.dart';
import 'briefing_pane.dart';

/// The landing screen: Briefing on the left, Edition on the right.
/// Below 1024px, the Edition collapses into a bottom sheet reachable
/// via the floating "Coach" button.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const double _twoPaneBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: PaperGrain(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _twoPaneBreakpoint;
            if (isWide) {
              return const Row(
                children: [
                  Expanded(flex: 6, child: BriefingPane()),
                  _VerticalRule(),
                  Expanded(
                    flex: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.paper),
                      child: EditionRail(),
                    ),
                  ),
                ],
              );
            }
            return const _StackedLayout();
          },
        ),
      ),
    );
  }
}

class _StackedLayout extends StatelessWidget {
  const _StackedLayout();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BriefingPane(),
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.oxblood,
            foregroundColor: AppColors.paper,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            onPressed: () => _openEditionSheet(context),
            label: const Text('COACH'),
          ),
        ),
      ],
    );
  }

  void _openEditionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.9,
        child: EditionRail(),
      ),
    );
  }
}

class _VerticalRule extends StatelessWidget {
  const _VerticalRule();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: AppColors.ruleGray,
    );
  }
}
