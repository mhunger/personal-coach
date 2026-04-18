import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_coach/main.dart';

void main() {
  testWidgets('App boots and renders the greeting', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PersonalCoachApp()));
    await tester.pump();
    expect(find.textContaining('Good morning'), findsOneWidget);
  });
}
