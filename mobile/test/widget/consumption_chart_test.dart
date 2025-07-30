import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/consumption_chart.dart';

void main() {
  testWidgets('ConsumptionChart renders correctly with data', (WidgetTester tester) async {
    final testData = [
      ConsumptionData(label: 'Jan', value: 10.0, date: DateTime(2023, 1, 1)),
      ConsumptionData(label: 'Feb', value: 20.0, date: DateTime(2023, 2, 1)),
      ConsumptionData(label: 'Mar', value: 15.0, date: DateTime(2023, 3, 1)),
      ConsumptionData(label: 'Apr', value: 25.0, date: DateTime(2023, 4, 1)),
      ConsumptionData(label: 'May', value: 30.0, date: DateTime(2023, 5, 1)),
    ];
    
    // Build the ConsumptionChart widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: testData,
              period: ChartPeriod.monthly,
              title: 'Water Consumption',
              subtitle: 'Monthly data',
              maxY: 50.0,
              height: 300.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
    
    // Verify that the title and subtitle are displayed
    expect(find.text('Water Consumption'), findsOneWidget);
    expect(find.text('Monthly data'), findsOneWidget);
  });

  testWidgets('ConsumptionChart renders empty state when no data', (WidgetTester tester) async {
    // Build the ConsumptionChart widget with empty data
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: [],
              period: ChartPeriod.monthly,
              title: 'Water Consumption',
              subtitle: 'Monthly data',
              maxY: 50.0,
              height: 300.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
    
    // Verify that the empty state message is displayed
    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('ConsumptionChart renders with different periods', (WidgetTester tester) async {
    final testData = [
      ConsumptionData(label: 'Jan', value: 10.0, date: DateTime(2023, 1, 1)),
      ConsumptionData(label: 'Feb', value: 20.0, date: DateTime(2023, 2, 1)),
      ConsumptionData(label: 'Mar', value: 15.0, date: DateTime(2023, 3, 1)),
    ];
    
    // Build the ConsumptionChart widget with daily period
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: testData,
              period: ChartPeriod.daily,
              title: 'Daily Consumption',
              subtitle: 'Daily data',
              maxY: 50.0,
              height: 300.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
    
    // Verify that the title is displayed
    expect(find.text('Daily Consumption'), findsOneWidget);
    
    // Rebuild with weekly period
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: testData,
              period: ChartPeriod.weekly,
              title: 'Weekly Consumption',
              subtitle: 'Weekly data',
              maxY: 50.0,
              height: 300.0,
            ),
          ),
        ),
      ),
    );
    
    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
    
    // Verify that the title is displayed
    expect(find.text('Weekly Consumption'), findsOneWidget);
  });

  testWidgets('ConsumptionChart renders with custom height', (WidgetTester tester) async {
    final testData = [
      ConsumptionData(label: 'Jan', value: 10.0, date: DateTime(2023, 1, 1)),
      ConsumptionData(label: 'Feb', value: 20.0, date: DateTime(2023, 2, 1)),
    ];
    
    // Build the ConsumptionChart widget with custom height
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: testData,
              period: ChartPeriod.monthly,
              title: 'Water Consumption',
              subtitle: 'Monthly data',
              maxY: 50.0,
              height: 200.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
    
    // Verify that the container has the correct height
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(ConsumptionChart),
        matching: find.byType(Container),
      ).first,
    );
    
    expect(container.constraints?.constraints.maxHeight, 200.0);
  });

  testWidgets('ConsumptionChart renders with custom maxY', (WidgetTester tester) async {
    final testData = [
      ConsumptionData(label: 'Jan', value: 10.0, date: DateTime(2023, 1, 1)),
      ConsumptionData(label: 'Feb', value: 20.0, date: DateTime(2023, 2, 1)),
    ];
    
    // Build the ConsumptionChart widget with custom maxY
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ConsumptionChart(
              data: testData,
              period: ChartPeriod.monthly,
              title: 'Water Consumption',
              subtitle: 'Monthly data',
              maxY: 100.0,
              height: 300.0,
            ),
          ),
        ),
      ),
    );

    // Verify that the chart is rendered
    expect(find.byType(ConsumptionChart), findsOneWidget);
  });
}