import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../shared/widgets/edition_stamp.dart';
import '../../shared/widgets/paper_card.dart';
import '../../shared/widgets/rule_divider.dart';
import '../domain/coach_turn.dart';
import '../domain/component.dart';
import 'chat_composer.dart';
import 'coach_providers.dart';
import 'components/component_renderer.dart';

/// The Edition rail — live coach stream.
///
/// Above the composer, three bands: the published conversation (most recent
/// at the bottom), a thinking indicator when the coach is working, and
/// today's opening suggestions (hidden once the conversation starts).
class EditionRail extends ConsumerWidget {
  const EditionRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation = ref.watch(conversationNotifierProvider);
    final suggestions = ref.watch(todaySuggestionsProvider);
    final hasConversation = conversation.turns.isNotEmpty;

    return Container(
      color: AppColors.paper,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(36, 48, 36, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(hasConversation: hasConversation),
                  const RuleDivider(verticalPadding: 12),
                  if (!hasConversation)
                    suggestions.when(
                      loading: () => const _LoadingBlock(
                          label: 'Coach is reading your brief…'),
                      error: (e, _) => _ErrorBlock(message: e.toString()),
                      data: (components) => _ComponentStream(
                        components: components,
                        keyPrefix: 'suggestion',
                      ),
                    ),
                  for (var i = 0; i < conversation.turns.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _TurnView(turn: conversation.turns[i], index: i),
                  ],
                  if (conversation.isSending) ...[
                    const SizedBox(height: 16),
                    const _LoadingBlock(label: 'Coach is composing…'),
                  ],
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.ruleGray)),
            ),
            padding: const EdgeInsets.fromLTRB(36, 20, 36, 28),
            child: const ChatComposer(),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final bool hasConversation;

  const _Header({required this.hasConversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EDITION', style: AppTypography.sectionTag),
        const SizedBox(height: 6),
        Text(
          hasConversation ? 'In conversation.' : 'For today.',
          style: AppTypography.title,
        ),
        const SizedBox(height: 4),
        const EditionStamp(text: 'Coach · live'),
        Row(
          children: [
            const Spacer(),
            TextButton(
              onPressed: () => ref.invalidate(todaySuggestionsProvider),
              child: const Text('REFRESH SUGGESTIONS'),
            ),
          ],
        ),
      ],
    );
  }
}

class _TurnView extends StatelessWidget {
  final CoachTurn turn;
  final int index;

  const _TurnView({required this.turn, required this.index});

  @override
  Widget build(BuildContext context) {
    if (turn.role == TurnRole.user) {
      return _UserLetter(
        text: _firstText(turn.components),
      );
    }
    return _ComponentStream(
      components: turn.components,
      keyPrefix: 'coach-$index',
    );
  }

  String _firstText(List<Component> components) {
    for (final c in components) {
      if (c is TextBlockComponent) return c.content;
    }
    return '';
  }
}

class _UserLetter extends StatelessWidget {
  final String text;

  const _UserLetter({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            text,
            textAlign: TextAlign.right,
            style: AppTypography.body.copyWith(color: AppColors.oxblood),
          ),
          const SizedBox(height: 2),
          Text('— M', style: AppTypography.editionStamp),
        ],
      ),
    );
  }
}

class _ComponentStream extends StatelessWidget {
  final List<Component> components;
  final String keyPrefix;

  const _ComponentStream({required this.components, required this.keyPrefix});

  @override
  Widget build(BuildContext context) {
    if (components.isEmpty) {
      return PaperCard(
        child: Text(
          'No components to show.',
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
            key: ValueKey('$keyPrefix-$i'),
            index: i,
            child: ComponentRenderer(component: components[i]),
          ),
        ],
      ],
    );
  }
}

class _RevealingComponent extends StatefulWidget {
  final int index;
  final Widget child;

  const _RevealingComponent({
    super.key,
    required this.index,
    required this.child,
  });

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
  final String label;

  const _LoadingBlock({required this.label});

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
          Text(label, style: AppTypography.coachVoice),
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
            'The sidecar didn\'t respond. Make sure the coach-sidecar '
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
