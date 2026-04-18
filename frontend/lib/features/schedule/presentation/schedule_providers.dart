import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_providers.dart';
import '../data/schedule_repository_impl.dart';
import '../domain/schedule_repository.dart';
import '../domain/weekly_schedule.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepositoryImpl(ref.watch(apiClientProvider)),
);

final scheduleForWeekProvider =
    FutureProvider.family<WeeklySchedule, String>((ref, isoWeek) {
  return ref.watch(scheduleRepositoryProvider).fetch(isoWeek);
});
