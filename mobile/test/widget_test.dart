// Basic Flutter widget test for BurrowMind app.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burrowmind/main.dart';

void main() {
  testWidgets('BurrowMind app launches', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BurrowMindApp(),
      ),
    );

    // Verify that the app launches successfully
    await tester.pump();
  });
}
