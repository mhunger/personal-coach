import 'package:flutter/material.dart';

import '../domain/busy_block.dart';
import '../domain/weekly_schedule.dart';

class ScheduleMapper {
  const ScheduleMapper._();

  static WeeklySchedule fromJson(Map<String, dynamic> json) {
    final blocks = (json['busyBlocks'] as List<dynamic>? ?? [])
        .map((raw) => _busyBlockFromJson(raw as Map<String, dynamic>))
        .toList();
    return WeeklySchedule(
      id: json['id'] as int?,
      isoWeek: json['isoWeek'] as String,
      notes: json['notes'] as String?,
      busyBlocks: blocks,
    );
  }

  static BusyBlock _busyBlockFromJson(Map<String, dynamic> json) {
    return BusyBlock(
      day: _weekdayFromName(json['day'] as String),
      startTime: _parseTime(json['startTime'] as String),
      endTime: _parseTime(json['endTime'] as String),
      label: json['label'] as String? ?? '',
    );
  }

  static int _weekdayFromName(String name) {
    const order = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY',
      'SATURDAY', 'SUNDAY'];
    final idx = order.indexOf(name.toUpperCase());
    return idx < 0 ? 1 : idx + 1;
  }

  static TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
