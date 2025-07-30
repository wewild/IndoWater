import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/app_bar.dart';

void main() {
  testWidgets('AppTopBar renders correctly with title', (WidgetTester tester) async {
    // Build the AppTopBar widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(title: 'Test Title'),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the title is displayed
    expect(find.text('Test Title'), findsOneWidget);
  });

  testWidgets('AppTopBar renders with actions', (WidgetTester tester) async {
    // Build the AppTopBar widget with actions
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(
            title: 'Test Title',
            actions: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the title is displayed
    expect(find.text('Test Title'), findsOneWidget);
    
    // Verify that the actions are displayed
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('AppTopBar renders with leading icon', (WidgetTester tester) async {
    bool leadingWasTapped = false;
    
    // Build the AppTopBar widget with a leading icon
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(
            title: 'Test Title',
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                leadingWasTapped = true;
              },
            ),
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the leading icon is displayed
    expect(find.byIcon(Icons.menu), findsOneWidget);
    
    // Tap the leading icon
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump();
    
    // Verify that the callback was called
    expect(leadingWasTapped, isTrue);
  });

  testWidgets('AppTopBar renders with bottom widget', (WidgetTester tester) async {
    // Build the AppTopBar widget with a bottom widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(
            title: 'Test Title',
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Container(
                height: 48.0,
                color: Colors.blue,
                child: Center(
                  child: Text('Bottom Widget'),
                ),
              ),
            ),
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the bottom widget is displayed
    expect(find.text('Bottom Widget'), findsOneWidget);
  });

  testWidgets('AppSearchBar renders correctly', (WidgetTester tester) async {
    final controller = TextEditingController();
    
    // Build the AppSearchBar widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppSearchBar(
            controller: controller,
            hintText: 'Search...',
            onClear: () {},
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the search field is displayed
    expect(find.byType(TextField), findsOneWidget);
    
    // Verify that the hint text is displayed
    expect(find.text('Search...'), findsOneWidget);
  });

  testWidgets('AppSearchBar calls onClear when clear button is tapped', (WidgetTester tester) async {
    final controller = TextEditingController(text: 'Test search');
    bool clearWasTapped = false;
    
    // Build the AppSearchBar widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppSearchBar(
            controller: controller,
            hintText: 'Search...',
            onClear: () {
              clearWasTapped = true;
            },
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the clear button is displayed
    expect(find.byIcon(Icons.clear), findsOneWidget);
    
    // Tap the clear button
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pump();
    
    // Verify that the callback was called
    expect(clearWasTapped, isTrue);
  });

  testWidgets('AppTabBar renders correctly with tabs', (WidgetTester tester) async {
    final tabController = TabController(length: 3, vsync: const TestVSync());
    
    // Build the AppTabBar widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(
            title: 'Test Title',
            bottom: AppTabBar(
              tabController: tabController,
              tabs: const ['Tab 1', 'Tab 2', 'Tab 3'],
            ),
          ),
          body: Container(),
        ),
      ),
    );

    // Verify that the app bar is rendered
    expect(find.byType(AppBar), findsOneWidget);
    
    // Verify that the tabs are displayed
    expect(find.text('Tab 1'), findsOneWidget);
    expect(find.text('Tab 2'), findsOneWidget);
    expect(find.text('Tab 3'), findsOneWidget);
  });
}

// Helper class for TabController
class TestVSync extends TickerProvider {
  const TestVSync();
  
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}