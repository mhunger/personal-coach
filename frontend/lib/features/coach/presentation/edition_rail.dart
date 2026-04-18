import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../shared/widgets/edition_stamp.dart';
import '../../shared/widgets/paper_card.dart';
import '../../shared/widgets/rule_divider.dart';

/// The persistent right-hand rail — the coach's "Edition" stream.
/// Renders components published by the agent.
///
/// v1 (step 5): static placeholder content. Step 8 replaces this with
/// suggestions fetched from the sidecar; step 9 adds the chat input and
/// the full component-stream renderer.
class EditionRail extends StatelessWidget {
  const EditionRail({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paper,
      padding: const EdgeInsets.fromLTRB(36, 48, 36, 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EDITION', style: AppTypography.sectionTag),
            const SizedBox(height: 6),
            Text('For today.', style: AppTypography.title),
            const SizedBox(height: 4),
            const EditionStamp(text: 'Coach · live'),
            const RuleDivider(verticalPadding: 20),
            const _PlaceholderSuggestion(
              tag: 'FOR TODAY',
              heading: 'Move the heavy session to Wednesday morning.',
              body: 'Your Tuesday runs long and Wednesday opens up at 07:30. '
                  'Shift the upper-body block there; keep today light.',
            ),
            const SizedBox(height: 16),
            const _PlaceholderSuggestion(
              tag: 'THIS WEEK',
              heading: 'Dinner with Lena on Thursday — keep it flexible.',
              body: 'I\'ll plan meal-prep that survives a wine-and-pasta evening '
                  'without wrecking Friday\'s training.',
            ),
            const SizedBox(height: 24),
            Text('Live coach arriving in step 8.',
                style: AppTypography.coachVoice),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderSuggestion extends StatelessWidget {
  final String tag;
  final String heading;
  final String body;

  const _PlaceholderSuggestion({
    required this.tag,
    required this.heading,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: AppTypography.metaTag),
          const SizedBox(height: 10),
          Text(heading, style: AppTypography.headline),
          const SizedBox(height: 10),
          Text(body, style: AppTypography.body),
        ],
      ),
    );
  }
}
