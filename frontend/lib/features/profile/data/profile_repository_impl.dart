import '../../../core/api/api_client.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import 'profile_mapper.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient api;

  ProfileRepositoryImpl(this.api);

  @override
  Future<Profile> fetch() async {
    final json = await api.get('/api/profile') as Map<String, dynamic>;
    return ProfileMapper.fromJson(json);
  }
}
