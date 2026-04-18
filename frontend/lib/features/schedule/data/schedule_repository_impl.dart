import '../../../core/api/api_client.dart';
import '../domain/schedule_repository.dart';
import '../domain/weekly_schedule.dart';
import 'schedule_mapper.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ApiClient api;

  ScheduleRepositoryImpl(this.api);

  @override
  Future<WeeklySchedule> fetch(String isoWeek) async {
    final json = await api.get('/api/schedule', query: {'week': isoWeek})
        as Map<String, dynamic>;
    return ScheduleMapper.fromJson(json);
  }
}
