import 'busy_block.dart';

class WeeklySchedule {
  final int? id;
  final String isoWeek;
  final String? notes;
  final List<BusyBlock> busyBlocks;

  const WeeklySchedule({
    this.id,
    required this.isoWeek,
    this.notes,
    this.busyBlocks = const [],
  });
}
