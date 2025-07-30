import 'package:flutter/material.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';

class TopupFailedScreen extends StatelessWidget {
  final double amount;
  final String error;

  const TopupFailedScreen({
    Key? key,
    required this.amount,
    required this.error,
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
              // Failed icon
              Icon(
                Icons.error,
                size: 100,
                color: Constants.waterError,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Failed message
              Text(
                'Top-up Failed',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.waterError,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginMedium),
              Text(
                'Your top-up transaction could not be completed.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Error details
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
                    Text(
                      'Error Details',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Text(
                      error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Constants.waterError,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Buttons
              AppButton(
                text: 'Try Again',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.topup);
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
              const SizedBox(height: Constants.marginMedium),
              TextButton(
                onPressed: () {
                  // Contact support
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.support_agent,
                      size: Constants.iconSizeSmall,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: Constants.marginSmall),
                    Text(
                      'Contact Support',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}