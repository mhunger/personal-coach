import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/iso_week.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../schedule/domain/busy_block.dart';
import '../../schedule/domain/weekly_schedule.dart';
import '../../schedule/presentation/schedule_providers.dart';
import '../../shared/widgets/edition_stamp.dart';
import '../../shared/widgets/paper_card.dart';
import '../../shared/widgets/rule_divider.dart';
import '../../shared/widgets/section_header.dart';

/// Left pane — "Today". Greeting + schedule + training placeholder.
class BriefingPane extends ConsumerWidget {
  const BriefingPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final profile = ref.watch(profileProvider);
    final schedule = ref.watch(scheduleForWeekProvider(isoWeekString(now)));

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(48, 48, 48, 48),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditionStamp(text: _dateLine(now)),
            const SizedBox(height: 10),
            profile.when(
              loading: () =>
                  Text('Good morning.', style: AppTypography.display),
              error: (e, _) => _ErrorBlock(message: e.toString()),
              data: (p) => Text(
                'Good morning, Michael.',
                style: AppTypography.display,
              ),
            ),
            const SizedBox(height: 6),
            profile.maybeWhen(
              data: (p) => Text(
                p.primaryGoal ?? 'Today\'s brief.',
                style: AppTypography.coachVoice,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const RuleDivider(verticalPadding: 28),

            const SectionHeader('Training'),
            PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '45m · Upper Body · 07:30',
                    style: AppTypography.headline,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Placeholder — replaced when the coach publishes your plan.',
                    style: AppTypography.body.copyWith(color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),

            const RuleDivider(verticalPadding: 28),

            const SectionHeader('Calendar'),
            schedule.when(
              loading: () => const _LoadingLine(),
              error: (e, _) => _ErrorBlock(message: e.toString()),
              data: (s) => _CalendarGlance(schedule: s, today: now),
            ),
          ],
        ),
      ),
    );
  }

  String _dateLine(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final wd = weekdays[d.weekday - 1];
    return '$wd ${d.day} ${months[d.month - 1]} · ${isoWeekString(d)}';
  }
}

class _CalendarGlance extends StatelessWidget {
  final WeeklySchedule schedule;
  final DateTime today;

  const _CalendarGlance({required this.schedule, required this.today});

  @override
  Widget build(BuildContext context) {
    final todays = schedule.busyBlocks
        .where((b) => b.day == today.weekday)
        .toList()
      ..sort((a, b) => _minutes(a.startTime).compareTo(_minutes(b.startTime)));

    if (todays.isEmpty) {
      return PaperCard(
        child: Text(
          'No busy blocks logged for today. Ask the coach to sync your calendar.',
          style: AppTypography.body.copyWith(color: AppColors.inkSoft),
        ),
      );
    }

    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < todays.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _CalendarRow(block: todays[i]),
          ],
        ],
      ),
    );
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;
}

class _CalendarRow extends StatelessWidget {
  final BusyBlock block;

  const _CalendarRow({required this.block});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '${_fmt(block.startTime)}–${_fmt(block.endTime)}',
            style: AppTypography.numericMedium,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(block.label, style: AppTypography.body),
        ),
      ],
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text('Loading…',
          style: AppTypography.body.copyWith(color: AppColors.inkSoft)),
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
          Text('BACKEND UNREACHABLE', style: AppTypography.metaTag),
          const SizedBox(height: 8),
          Text(message, style: AppTypography.numericSmall),
        ],
      ),
    );
  }
}
