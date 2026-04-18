import 'package:flutter/material.dart';

import '../../../core/theme/typography.dart';

/// A marginal date stamp — Fraunces italic, quiet, lives in the left margin
/// of the briefing pane or next to a card. Like the date on a journal page.
class EditionStamp extends StatelessWidget {
  final String text;
  final TextAlign align;

  const EditionStamp({
    super.key,
    required this.text,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: align, style: AppTypography.editionStamp);
  }
}
