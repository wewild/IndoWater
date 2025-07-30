import 'package:flutter/material.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';

class TopupSuccessScreen extends StatelessWidget {
  final double amount;
  final String paymentId;

  const TopupSuccessScreen({
    Key? key,
    required this.amount,
    required this.paymentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingLarge),
          child: Column(
            children: [
              const Spacer(),
              // Success icon
              Icon(
                Icons.check_circle,
                size: 100,
                color: Constants.waterSuccess,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Success message
              Text(
                'Top-up Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.waterSuccess,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginMedium),
              Text(
                'Your account has been topped up successfully.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Amount
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'Amount',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Text(
                      '${Constants.currencySymbol} ${amount.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: Constants.marginMedium),
                    Divider(
                      height: 1,
                      thickness: Constants.dividerThickness,
                      color: theme.dividerColor,
                    ),
                    const SizedBox(height: Constants.marginMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction ID',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          paymentId,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          _getFormattedDate(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buttons
              AppButton(
                text: 'View Receipt',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    AppRoutes.paymentDetails,
                    arguments: {'payment_id': paymentId},
                  );
                },
                isFullWidth: true,
              ),
              const SizedBox(height: Constants.marginMedium),
              AppButton(
                text: 'Back to Dashboard',
                type: ButtonType.outline,
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }
}