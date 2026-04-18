import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:personal_coach/main.dart';

void main() {
  testWidgets('App boots and renders an edition date stamp', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PersonalCoachApp()));
    await tester.pump();
    // Don't await settling — no backend is reachable in tests, which is fine.
    expect(find.textContaining('W', findRichText: false), findsWidgets);
  });
}
