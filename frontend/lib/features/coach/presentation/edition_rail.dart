import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../shared/widgets/edition_stamp.dart';
import '../../shared/widgets/paper_card.dart';
import '../../shared/widgets/rule_divider.dart';
import '../domain/component.dart';
import 'coach_providers.dart';
import 'components/component_renderer.dart';

/// The Edition rail — the coach's "published stream". Step 8 renders live
/// suggestions from the sidecar; step 9 adds chat input and conversation
/// history.
class EditionRail extends ConsumerWidget {
  const EditionRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(todaySuggestionsProvider);

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
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => ref.invalidate(todaySuggestionsProvider),
                  child: const Text('REFRESH'),
                ),
              ],
            ),
            const RuleDivider(verticalPadding: 12),
            suggestions.when(
              loading: () => const _LoadingBlock(),
              error: (e, _) => _ErrorBlock(message: e.toString()),
              data: (components) => _ComponentStream(components: components),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComponentStream extends StatelessWidget {
  final List<Component> components;

  const _ComponentStream({required this.components});

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) {
      return PaperCard(
        child: Text(
          'No suggestions right now — try refreshing, or start a conversation.',
          style: AppTypography.body.copyWith(color: AppColors.inkSoft),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < components.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _RevealingComponent(
            index: i,
            child: ComponentRenderer(component: components[i]),
          ),
        ],
      ],
    );
  }
}

/// Staggered reveal: each published component fades + rises into place,
/// 280ms each, 80ms stagger. Feels like pages printing.
class _RevealingComponent extends StatefulWidget {
  final int index;
  final Widget child;

  const _RevealingComponent({required this.index, required this.child});

  @override
  State<_RevealingComponent> createState() => _RevealingComponentState();
}

class _RevealingComponentState extends State<_RevealingComponent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    Future.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Opacity(
        opacity: _c.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _c.value) * 12),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 1.2),
          ),
          const SizedBox(width: 14),
          Text('Coach is reading your brief…',
              style: AppTypography.coachVoice),
        ],
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final String message;

  const _ErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      color: AppColors.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COACH UNAVAILABLE', style: AppTypography.metaTag),
          const SizedBox(height: 10),
          Text(
            'The sidecar didn\'t respond. Make sure the `coach-sidecar` '
            'container is healthy and ANTHROPIC_API_KEY is set.',
            style: AppTypography.body,
          ),
          const SizedBox(height: 10),
          Text(message, style: AppTypography.numericSmall),
        ],
      ),
    );
  }
}
