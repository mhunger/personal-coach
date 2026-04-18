import 'weekly_schedule.dart';

abstract class ScheduleRepository {
  Future<WeeklySchedule> fetch(String isoWeek);
}
