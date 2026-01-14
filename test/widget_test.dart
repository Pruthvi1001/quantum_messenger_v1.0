// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_messenger41/main.dart';
import 'package:quantum_messenger41/state/app_state.dart';

void main() {
  testWidgets('App renders main screen with bottom navigation', (WidgetTester tester) async {
    // Initialize AppState
    final appState = AppState();
    await appState.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(QuantumMessengerApp(appState: appState));

    // Verify that the main screen is rendered.
    expect(find.byType(MainScreen), findsOneWidget);

    // Verify that the bottom navigation bar is present.
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify that the "Discovery" tab is present.
    expect(find.text('Discovery'), findsOneWidget);
  });
}
