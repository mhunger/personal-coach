import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/paper_grain.dart';
import 'core/theme/typography.dart';
import 'features/shared/widgets/corner_mark.dart';
import 'features/shared/widgets/edition_stamp.dart';
import 'features/shared/widgets/paper_card.dart';
import 'features/shared/widgets/rule_divider.dart';
import 'features/shared/widgets/section_header.dart';

void main() {
  runApp(const ProviderScope(child: PersonalCoachApp()));
}

class PersonalCoachApp extends StatelessWidget {
  const PersonalCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const _ThemePreview(),
    );
  }
}

/// Temporary theme preview — replaced in step 5 by the real two-pane shell.
class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    return PaperGrain(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EditionStamp(text: 'Sat 18 April · Week 17'),
                const SizedBox(height: 8),
                Text('Good morning, Michael.', style: AppTypography.display),
                const SizedBox(height: 6),
                Text('Theme preview — replaced by Today in step 5.',
                    style: AppTypography.coachVoice),
                const RuleDivider(verticalPadding: 24),
                const SectionHeader('Training'),
                PaperCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('45m · Upper Body · 07:30',
                          style: AppTypography.headline),
                      const SizedBox(height: 12),
                      Text('3 × 8  bench  ·  3 × 6  row  ·  2 × 10  press',
                          style: AppTypography.numericMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const CornerMark(size: 10),
                    const SizedBox(width: 10),
                    Text('corner mark sample', style: AppTypography.uiLabel),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
