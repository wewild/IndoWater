import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/app_text_field.dart';

void main() {
  testWidgets('AppTextField renders correctly with default props', (WidgetTester tester) async {
    // Build the AppTextField widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
              controller: TextEditingController(),
            ),
          ),
        ),
      ),
    );

    // Verify that the label and hint are rendered
    expect(find.text('Test Label'), findsOneWidget);
    expect(find.text('Test Hint'), findsOneWidget);
    
    // Verify that the text field is rendered
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('AppTextField shows error message when validator returns error', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    
    // Build the AppTextField widget with a validator
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Center(
              child: AppTextField(
                label: 'Test Label',
                hint: 'Test Hint',
                controller: TextEditingController(),
                validator: (value) => value!.isEmpty ? 'Field cannot be empty' : null,
              ),
            ),
          ),
        ),
      ),
    );

    // Validate the form
    formKey.currentState!.validate();
    await tester.pump();

    // Verify that the error message is shown
    expect(find.text('Field cannot be empty'), findsOneWidget);
  });

  testWidgets('AppTextField updates text when user types', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    // Build the AppTextField widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
              controller: controller,
            ),
          ),
        ),
      ),
    );

    // Enter text
    await tester.enterText(find.byType(TextFormField), 'Hello World');
    
    // Verify that the controller has the correct text
    expect(controller.text, 'Hello World');
  });

  testWidgets('AppTextField shows prefix icon when provided', (WidgetTester tester) async {
    // Build the AppTextField widget with a prefix icon
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
              controller: TextEditingController(),
              prefixIcon: Icons.email,
            ),
          ),
        ),
      ),
    );

    // Verify that the prefix icon is shown
    expect(find.byIcon(Icons.email), findsOneWidget);
  });

  testWidgets('AppTextField shows suffix icon when provided', (WidgetTester tester) async {
    // Build the AppTextField widget with a suffix icon
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
              controller: TextEditingController(),
              suffixIcon: Icons.visibility,
            ),
          ),
        ),
      ),
    );

    // Verify that the suffix icon is shown
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('AppTextField is disabled when enabled is false', (WidgetTester tester) async {
    // Build the AppTextField widget with enabled set to false
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
              controller: TextEditingController(),
              enabled: false,
            ),
          ),
        ),
      ),
    );

    // Verify that the text field is disabled
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.enabled, isFalse);
  });

  testWidgets('AppTextField obscures text when isPassword is true', (WidgetTester tester) async {
    // Build the AppTextField widget with isPassword set to true
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Password',
              hint: 'Enter password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          ),
        ),
      ),
    );

    // Verify that the text field obscures text
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.obscureText, isTrue);
    
    // Verify that the visibility toggle icon is shown
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    
    // Tap the visibility toggle icon
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    
    // Verify that the visibility icon has changed
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('AppTextField supports multiline when maxLines > 1', (WidgetTester tester) async {
    // Build the AppTextField widget with maxLines set to 3
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppTextField(
              label: 'Description',
              hint: 'Enter description',
              controller: TextEditingController(),
              maxLines: 3,
            ),
          ),
        ),
      ),
    );

    // Verify that the text field has multiple lines
    final textField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(textField.maxLines, 3);
  });
}