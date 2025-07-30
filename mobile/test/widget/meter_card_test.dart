import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/meter_card.dart';
import 'package:indowater_mobile/utils/constants.dart';

void main() {
  testWidgets('MeterCard renders correctly with required props', (WidgetTester tester) async {
    // Build the MeterCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'active',
              balance: 100.0,
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the meter information is displayed
    expect(find.text('Home Meter'), findsOneWidget);
    expect(find.text('M12345'), findsOneWidget);
    expect(find.text('123 Main St'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    
    // Verify that the balance is displayed
    expect(find.textContaining('100'), findsOneWidget);
    
    // Verify that the last reading is displayed
    expect(find.textContaining('50'), findsOneWidget);
    
    // Verify that the view details button is displayed
    expect(find.text('View Details'), findsOneWidget);
  });

  testWidgets('MeterCard calls onTap when tapped', (WidgetTester tester) async {
    bool wasTapped = false;
    
    // Build the MeterCard widget with a callback
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'active',
              balance: 100.0,
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {
                wasTapped = true;
              },
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Tap the card
    await tester.tap(find.byType(Card));
    await tester.pump();

    // Verify that the callback was called
    expect(wasTapped, isTrue);
  });

  testWidgets('MeterCard calls onViewDetails when view details button is tapped', (WidgetTester tester) async {
    bool viewDetailsWasTapped = false;
    
    // Build the MeterCard widget with a callback
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'active',
              balance: 100.0,
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {
                viewDetailsWasTapped = true;
              },
            ),
          ),
        ),
      ),
    );

    // Find and tap the view details button
    await tester.tap(find.text('View Details'));
    await tester.pump();

    // Verify that the callback was called
    expect(viewDetailsWasTapped, isTrue);
  });

  testWidgets('MeterCard displays low balance warning when balance is low', (WidgetTester tester) async {
    // Build the MeterCard widget with a low balance
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'active',
              balance: Constants.lowBalanceThreshold - 1, // Set balance below threshold
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the low balance warning is displayed
    expect(find.text('Low Balance!'), findsOneWidget);
  });

  testWidgets('MeterCard displays different status colors based on status', (WidgetTester tester) async {
    // Build the MeterCard widget with inactive status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'inactive',
              balance: 100.0,
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the inactive status is displayed
    expect(find.text('INACTIVE'), findsOneWidget);
    
    // Rebuild with maintenance status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'maintenance',
              balance: 100.0,
              lastReading: 50.0,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify that the maintenance status is displayed
    expect(find.text('MAINTENANCE'), findsOneWidget);
  });

  testWidgets('MeterCard formats currency and volume correctly', (WidgetTester tester) async {
    // Build the MeterCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: MeterCard(
              meterId: '123',
              meterNumber: 'M12345',
              nickname: 'Home Meter',
              address: '123 Main St',
              status: 'active',
              balance: 1234.56,
              lastReading: 789.01,
              lastReadingDate: DateTime(2023, 1, 1),
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the balance is formatted correctly
    expect(find.textContaining('${Constants.currencySymbol} 1234'), findsOneWidget);
    
    // Verify that the last reading is formatted correctly
    expect(find.textContaining('789'), findsOneWidget);
    expect(find.textContaining(Constants.volumeUnit), findsOneWidget);
  });
}