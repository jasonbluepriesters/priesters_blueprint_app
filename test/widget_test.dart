import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Imports your actual app!
import 'package:priesters_blueprint_app/main.dart';

void main() {
  testWidgets('App boots up without crashing smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap it in ProviderScope because your app relies on Riverpod state management!
    await tester.pumpWidget(const ProviderScope(child: PriestersBlueprintApp()));

    // Simply verify that the core MaterialApp shell renders successfully
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}