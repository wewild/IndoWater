import 'package:flutter/material.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/utils/constants.dart';

class MeterCard extends StatelessWidget {
  final String meterId;
  final String meterNumber;
  final String nickname;
  final String address;
  final String status;
  final double balance;
  final double lastReading;
  final DateTime lastReadingDate;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  const MeterCard({
    Key? key,
    required this.meterId,
    required this.meterNumber,
    required this.nickname,
    required this.address,
    required this.status,
    required this.balance,
    required this.lastReading,
    required this.lastReadingDate,
    this.onTap,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine status color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Constants.waterSuccess;
        break;
      case 'inactive':
        statusColor = Constants.waterError;
        break;
      case 'maintenance':
        statusColor = Constants.waterWarning;
        break;
      case 'disconnected':
        statusColor = Constants.waterError;
        break;
      default:
        statusColor = Constants.waterInfo;
    }
    
    // Format balance
    final formattedBalance = '${Constants.currencySymbol} ${balance.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}';
    
    // Format last reading
    final formattedLastReading = '${lastReading.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
    
    // Format last reading date
    final formattedLastReadingDate = '${lastReadingDate.day}/${lastReadingDate.month}/${lastReadingDate.year}';
    
    // Determine if balance is low
    final isLowBalance = balance <= Constants.lowBalanceThreshold;
    
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: Constants.marginMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Meter icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: theme.primaryColor,
                  size: Constants.iconSizeMedium,
                ),
              ),
              const SizedBox(width: Constants.marginMedium),
              // Meter info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meter: $meterNumber',
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
                child: Text(
                  status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
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
          // Balance and reading
          Row(
            children: [
              // Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: Constants.iconSizeSmall,
                          color: isLowBalance ? Constants.waterError : theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedBalance,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isLowBalance ? Constants.waterError : theme.textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    if (isLowBalance) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Low Balance!',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Constants.waterError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Last reading
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Reading',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: Constants.iconSizeSmall,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedLastReading,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedLastReadingDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.textTheme.labelSmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.marginMedium),
          // Address
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: Constants.iconSizeSmall,
                color: theme.hintColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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