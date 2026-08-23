import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_fashion_mobile/core/theme/app_theme.dart';

void main() {
  testWidgets('App theme builds a MaterialApp without crashing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: Center(child: Text('Aura Fashion'))),
      ),
    );

    expect(find.text('Aura Fashion'), findsOneWidget);
  });
}
