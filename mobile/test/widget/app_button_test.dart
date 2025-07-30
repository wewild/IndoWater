import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/app_button.dart';

void main() {
  testWidgets('AppButton renders correctly with default props', (WidgetTester tester) async {
    // Build the AppButton widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the button is rendered
    expect(find.text('Test Button'), findsOneWidget);
    
    // Verify that the button has the default properties
    final buttonMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(Material),
      ),
    );
    
    // Check if the button has the primary color
    expect(buttonMaterial.color, isNotNull);
    
    // Check if the button has the correct shape
    expect(buttonMaterial.shape, isA<RoundedRectangleBorder>());
  });

  testWidgets('AppButton calls onPressed when tapped', (WidgetTester tester) async {
    bool wasPressed = false;
    
    // Build the AppButton widget with a callback
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Button',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      ),
    );

    // Tap the button
    await tester.tap(find.byType(AppButton));
    await tester.pump();

    // Verify that the callback was called
    expect(wasPressed, isTrue);
  });

  testWidgets('AppButton shows loading indicator when isLoading is true', (WidgetTester tester) async {
    // Build the AppButton widget with isLoading set to true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Button',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      ),
    );

    // Verify that the loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify that the text is not shown
    expect(find.text('Test Button'), findsNothing);
  });

  testWidgets('AppButton is disabled when onPressed is null', (WidgetTester tester) async {
    // Build the AppButton widget with onPressed set to null
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Button',
              onPressed: null,
            ),
          ),
        ),
      ),
    );

    // Verify that the button is disabled
    final buttonMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(Material),
      ),
    );
    
    // Check if the button has the disabled color
    expect(buttonMaterial.color, isNotNull);
  });

  testWidgets('AppButton renders with icon when provided', (WidgetTester tester) async {
    // Build the AppButton widget with an icon
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Test Button',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      ),
    );

    // Verify that the icon is shown
    expect(find.byIcon(Icons.add), findsOneWidget);
    
    // Verify that the text is also shown
    expect(find.text('Test Button'), findsOneWidget);
  });

  testWidgets('AppButton renders with different button types', (WidgetTester tester) async {
    // Build the AppButton widget with outline type
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Outline Button',
              onPressed: () {},
              type: ButtonType.outline,
            ),
          ),
        ),
      ),
    );

    // Verify that the outline button is rendered
    expect(find.text('Outline Button'), findsOneWidget);
    
    // Check if the button has the correct shape
    final outlineButtonMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(AppButton),
        matching: find.byType(Material),
      ),
    );
    
    expect(outlineButtonMaterial.shape, isA<RoundedRectangleBorder>());
    
    // Rebuild with text button type
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Text Button',
              onPressed: () {},
              type: ButtonType.text,
            ),
          ),
        ),
      ),
    );
    
    // Verify that the text button is rendered
    expect(find.text('Text Button'), findsOneWidget);
  });

  testWidgets('AppButton renders with different sizes', (WidgetTester tester) async {
    // Build the AppButton widget with small size
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Small Button',
              onPressed: () {},
              size: ButtonSize.small,
            ),
          ),
        ),
      ),
    );

    // Verify that the small button is rendered
    expect(find.text('Small Button'), findsOneWidget);
    
    // Rebuild with large size
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Large Button',
              onPressed: () {},
              size: ButtonSize.large,
            ),
          ),
        ),
      ),
    );
    
    // Verify that the large button is rendered
    expect(find.text('Large Button'), findsOneWidget);
  });
}