import 'package:flutter/material.dart';

import '../../../core/theme/typography.dart';

/// A small-caps section tag preceded by an em-dash, followed by padding.
/// Example:  "— TRAINING —". Use at the top of editorial sections.
class SectionHeader extends StatelessWidget {
  final String label;

  const SectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '— ${label.toUpperCase()} —',
        style: AppTypography.sectionTag,
      ),
    );
  }
}
