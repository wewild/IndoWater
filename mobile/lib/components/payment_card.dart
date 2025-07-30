import 'package:flutter/material.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/utils/constants.dart';

enum PaymentCardType {
  history,
  upcoming,
  topup,
}

class PaymentCard extends StatelessWidget {
  final String paymentId;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String status;
  final String? paymentMethod;
  final String? meterNumber;
  final PaymentCardType type;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const PaymentCard({
    Key? key,
    required this.paymentId,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.status,
    this.paymentMethod,
    this.meterNumber,
    this.type = PaymentCardType.history,
    this.onTap,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine status color
    Color statusColor;
    IconData statusIcon;
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'paid':
        statusColor = Constants.waterSuccess;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
      case 'processing':
        statusColor = Constants.waterWarning;
        statusIcon = Icons.access_time;
        break;
      case 'failed':
      case 'declined':
      case 'expired':
        statusColor = Constants.waterError;
        statusIcon = Icons.error;
        break;
      case 'canceled':
        statusColor = theme.hintColor;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Constants.waterInfo;
        statusIcon = Icons.info;
    }
    
    // Format amount
    final formattedAmount = '${Constants.currencySymbol} ${amount.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}';
    
    // Format date
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    
    // Determine icon based on type
    IconData typeIcon;
    switch (type) {
      case PaymentCardType.history:
        typeIcon = Icons.receipt;
        break;
      case PaymentCardType.upcoming:
        typeIcon = Icons.event;
        break;
      case PaymentCardType.topup:
        typeIcon = Icons.account_balance_wallet;
        break;
    }
    
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: Constants.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Payment icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                ),
                child: Icon(
                  typeIcon,
                  color: theme.primaryColor,
                  size: Constants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: Constants.marginMedium),
              // Payment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Constants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 12,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.marginMedium),
          // Divider
          Divider(
            height: 1,
            thickness: Constants.dividerThickness,
            color: theme.dividerColor,
          ),
          const SizedBox(height: Constants.marginMedium),
          // Amount and date
          Row(
            children: [
              // Amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedAmount,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: Constants.iconSizeSmall,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.marginMedium),
          // Additional info
          if (paymentMethod != null || meterNumber != null)
            Row(
              children: [
                if (paymentMethod != null) ...[
                  // Payment method
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          paymentMethod!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                if (meterNumber != null) ...[
                  // Meter number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meter',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meterNumber!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          if (onViewDetails != null) ...[
            const SizedBox(height: Constants.marginMedium),
            // View details button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewDetails,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: Constants.iconSizeSmall,
                      color: theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}