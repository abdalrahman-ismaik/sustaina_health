import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghiraas/core/widgets/custom_button.dart';

void main() {
  group('Core Widget Tests', () {
    testWidgets('CustomButton should render correctly', (WidgetTester tester) async {
      // TODO: Implement custom button widget test
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              onPressed: null,
              text: 'Test Button',
            ),
          ),
        ),
      );
      
      expect(find.text('Test Button'), findsOneWidget);
    });
  });
}
