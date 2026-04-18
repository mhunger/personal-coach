import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/profile_repository_impl.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(apiClientProvider)),
);

final profileProvider = FutureProvider<Profile>(
  (ref) => ref.watch(profileRepositoryProvider).fetch(),
);
