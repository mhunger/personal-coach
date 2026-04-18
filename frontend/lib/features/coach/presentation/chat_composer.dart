import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import 'coach_providers.dart';

/// The chat input — a single line beneath the edition stream. Enter sends;
/// Shift+Enter inserts a newline. Disabled while the coach is thinking.
class ChatComposer extends ConsumerStatefulWidget {
  const ChatComposer({super.key});

  @override
  ConsumerState<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends ConsumerState<ChatComposer> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(conversationNotifierProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('— ASK ANYTHING —', style: AppTypography.sectionTag),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.enter): _SubmitIntent(),
                },
                child: Actions(
                  actions: {
                    _SubmitIntent: CallbackAction<_SubmitIntent>(
                      onInvoke: (_) {
                        _submit();
                        return null;
                      },
                    ),
                  },
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    enabled: !state.isSending,
                    maxLines: null,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    style: AppTypography.body,
                    decoration: const InputDecoration(
                      hintText: 'What do you need, Michael?',
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: state.isSending ? null : _submit,
              child: Text(state.isSending ? 'SENDING…' : 'SEND'),
            ),
          ],
        ),
        if (state.error != null) ...[
          const SizedBox(height: 8),
          Text(
            state.error!,
            style: AppTypography.numericSmall.copyWith(color: AppColors.oxblood),
          ),
        ],
      ],
    );
  }
}

class _SubmitIntent extends Intent {
  const _SubmitIntent();
}
