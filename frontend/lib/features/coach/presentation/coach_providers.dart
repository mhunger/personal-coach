import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/profile_providers.dart';
import '../data/coach_repository_impl.dart';
import '../domain/coach_repository.dart';
import '../domain/component.dart';

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => CoachRepositoryImpl(ref.watch(apiClientProvider)),
);

final todaySuggestionsProvider = FutureProvider<List<Component>>(
  (ref) => ref.watch(coachRepositoryProvider).fetchSuggestions(context: 'today'),
);
