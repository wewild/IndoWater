import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indowater_mobile/components/payment_card.dart';
import 'package:indowater_mobile/utils/constants.dart';

void main() {
  testWidgets('PaymentCard renders correctly with required props', (WidgetTester tester) async {
    final testDate = DateTime(2023, 1, 1);
    
    // Build the PaymentCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: testDate,
              status: 'success',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the card is rendered
    expect(find.byType(Card), findsOneWidget);
    
    // Verify that the payment information is displayed
    expect(find.text('Test Payment'), findsOneWidget);
    expect(find.text('Payment description'), findsOneWidget);
    
    // Verify that the amount is displayed
    expect(find.textContaining('100'), findsOneWidget);
    
    // Verify that the date is displayed
    expect(find.textContaining('1/1/2023'), findsOneWidget);
    
    // Verify that the status is displayed
    expect(find.text('SUCCESS'), findsOneWidget);
  });

  testWidgets('PaymentCard calls onTap when tapped', (WidgetTester tester) async {
    bool wasTapped = false;
    
    // Build the PaymentCard widget with a callback
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
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

  testWidgets('PaymentCard calls onViewDetails when view details button is tapped', (WidgetTester tester) async {
    bool viewDetailsWasTapped = false;
    
    // Build the PaymentCard widget with a callback
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
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

  testWidgets('PaymentCard displays different status colors based on status', (WidgetTester tester) async {
    // Build the PaymentCard widget with pending status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'pending',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the pending status is displayed
    expect(find.text('PENDING'), findsOneWidget);
    
    // Rebuild with failed status
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'failed',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify that the failed status is displayed
    expect(find.text('FAILED'), findsOneWidget);
  });

  testWidgets('PaymentCard formats currency correctly', (WidgetTester tester) async {
    // Build the PaymentCard widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 1234.56,
              date: DateTime(2023, 1, 1),
              status: 'success',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the amount is formatted correctly
    expect(find.textContaining('${Constants.currencySymbol} 1234'), findsOneWidget);
  });

  testWidgets('PaymentCard renders with payment method when provided', (WidgetTester tester) async {
    // Build the PaymentCard widget with payment method
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
              paymentMethod: 'Credit Card',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the payment method is displayed
    expect(find.text('Credit Card'), findsOneWidget);
  });

  testWidgets('PaymentCard renders with meter number when provided', (WidgetTester tester) async {
    // Build the PaymentCard widget with meter number
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Test Payment',
              description: 'Payment description',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
              meterNumber: 'M12345',
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the meter number is displayed
    expect(find.text('Meter: M12345'), findsOneWidget);
  });

  testWidgets('PaymentCard renders differently based on type', (WidgetTester tester) async {
    // Build the PaymentCard widget with topup type
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Top-up',
              description: 'Top-up transaction',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
              type: PaymentCardType.topup,
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );

    // Verify that the top-up type is rendered correctly
    expect(find.text('Top-up'), findsOneWidget);
    
    // Rebuild with history type
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PaymentCard(
              paymentId: '123',
              title: 'Bill Payment',
              description: 'Bill payment transaction',
              amount: 100.0,
              date: DateTime(2023, 1, 1),
              status: 'success',
              type: PaymentCardType.history,
              onTap: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      ),
    );
    
    // Verify that the history type is rendered correctly
    expect(find.text('Bill Payment'), findsOneWidget);
  });
}