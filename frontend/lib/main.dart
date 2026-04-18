import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/today/presentation/today_screen.dart';

void main() {
  runApp(const ProviderScope(child: PersonalCoachApp()));
}

class PersonalCoachApp extends StatelessWidget {
  const PersonalCoachApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Coach',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const TodayScreen(),
    );
  }
}
