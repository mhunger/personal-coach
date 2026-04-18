import 'package:flutter/material.dart';

import '../../../../core/theme/typography.dart';
import '../../domain/component.dart';

/// The coach speaking — Fraunces italic, indented, no bubble.
/// Feels like a handwritten note from an editor.
class TextBlockWidget extends StatelessWidget {
  final TextBlockComponent component;

  const TextBlockWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(component.content, style: AppTypography.coachVoice),
    );
  }
}
