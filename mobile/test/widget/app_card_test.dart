import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/app_card.dart';

void main() {
  testWidgets('AppCard renders correctly with default props', (WidgetTester tester) async {
    // Build the AppCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the child is rendered
    expect(find.text('Card Content'), findsOneWidget);
  });

  testWidgets('AppCard renders with custom padding', (WidgetTester tester) async {
    // Build the AppCard widget with custom padding
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              padding: const EdgeInsets.all(20.0),
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the child is rendered
    expect(find.text('Card Content'), findsOneWidget);
    
    // Verify that the padding is applied
    final paddingWidget = tester.widget<Padding>(
      find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      ),
    );
    
    expect(paddingWidget.padding, const EdgeInsets.all(20.0));
  });

  testWidgets('AppCard renders with custom color', (WidgetTester tester) async {
    // Build the AppCard widget with custom color
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              color: Colors.red,
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the color is applied
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.color, Colors.red);
  });

  testWidgets('AppCard renders with custom elevation', (WidgetTester tester) async {
    // Build the AppCard widget with custom elevation
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              elevation: 8.0,
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the elevation is applied
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.elevation, 8.0);
  });

  testWidgets('AppCard renders with custom border radius', (WidgetTester tester) async {
    // Build the AppCard widget with custom border radius
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              borderRadius: 20.0,
              child: Text('Card Content'),
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the border radius is applied
    final card = tester.widget<Card>(find.byType(Card));
    expect(card.shape, isA<RoundedRectangleBorder>());
    
    final shape = card.shape as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(20.0));
  });

  testWidgets('AppCardHeader renders correctly', (WidgetTester tester) async {
    // Build the AppCardHeader widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              child: Column(
                children: [
                  AppCardHeader(
                    title: 'Card Title',
                    subtitle: 'Card Subtitle',
                  ),
                  Text('Card Content'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Verify that the card header is rendered
    expect(find.byType(AppCardHeader), findsOneWidget);
    
    // Verify that the title and subtitle are rendered
    expect(find.text('Card Title'), findsOneWidget);
    expect(find.text('Card Subtitle'), findsOneWidget);
  });

  testWidgets('AppCardHeader renders with trailing widget', (WidgetTester tester) async {
    // Build the AppCardHeader widget with a trailing widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppCard(
              child: Column(
                children: [
                  AppCardHeader(
                    title: 'Card Title',
                    trailing: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ),
                  Text('Card Content'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Verify that the card header is rendered
    expect(find.byType(AppCardHeader), findsOneWidget);
    
    // Verify that the title is rendered
    expect(find.text('Card Title'), findsOneWidget);
    
    // Verify that the trailing widget is rendered
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
  });
}