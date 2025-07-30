import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final String paymentId;

  const PaymentDetailsScreen({
    Key? key,
    required this.paymentId,
  }) : super(key: key);

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _paymentDetails;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  Future<void> _loadPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final paymentDetails = await paymentService.getPaymentDetails(widget.paymentId);

      if (!mounted) return;

      setState(() {
        _paymentDetails = paymentDetails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppTopBar(title: 'Payment Details'),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppTopBar(title: 'Payment Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: Constants.marginMedium),
              Text(
                'Error loading payment details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Constants.marginSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Constants.marginLarge),
              AppButton(
                text: 'Retry',
                onPressed: _loadPaymentDetails,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      );
    }
    
    if (_paymentDetails == null) {
      return Scaffold(
        appBar: AppTopBar(title: 'Payment Details'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 64,
                color: theme.hintColor,
              ),
              const SizedBox(height: Constants.marginMedium),
              Text(
                'Payment not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Constants.marginSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                child: Text(
                  'The payment you are looking for does not exist or has been removed.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: Constants.marginLarge),
              AppButton(
                text: 'Go Back',
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icons.arrow_back,
              ),
            ],
          ),
        ),
      );
    }
    
    // Extract payment details
    final title = _paymentDetails!['title'] ?? 'Payment';
    final description = _paymentDetails!['description'] ?? 'Payment transaction';
    final amount = _paymentDetails!['amount'] ?? 0.0;
    final date = _paymentDetails!['date'] != null
        ? DateTime.parse(_paymentDetails!['date'])
        : DateTime.now();
    final status = _paymentDetails!['status'] ?? 'pending';
    final paymentMethod = _paymentDetails!['payment_method'];
    final meterNumber = _paymentDetails!['meter_number'];
    final transactionId = _paymentDetails!['transaction_id'] ?? '-';
    final referenceId = _paymentDetails!['reference_id'] ?? '-';
    final type = _paymentDetails!['type'] ?? 'payment';
    
    // Format amount
    final formattedAmount = '${Constants.currencySymbol} ${amount.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}';
    
    // Format date
    final formattedDate = '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Payment Details'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              AppCard(
                color: statusColor.withOpacity(0.1),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: Constants.iconSizeLarge,
                        ),
                        const SizedBox(width: Constants.marginMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.toUpperCase(),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusDescription(status),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing') ...[
                      const SizedBox(height: Constants.marginMedium),
                      AppButton(
                        text: 'Check Status',
                        onPressed: _loadPaymentDetails,
                        icon: Icons.refresh,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Constants.marginLarge),
              // Payment details
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCardHeader(
                      title: 'Payment Details',
                      subtitle: type == 'topup' ? 'Top-up Transaction' : 'Bill Payment',
                    ),
                    _buildDetailRow('Amount', formattedAmount),
                    _buildDetailRow('Date', formattedDate),
                    _buildDetailRow('Payment Method', paymentMethod ?? '-'),
                    if (meterNumber != null)
                      _buildDetailRow('Meter Number', meterNumber),
                    _buildDetailRow('Transaction ID', transactionId),
                    _buildDetailRow('Reference ID', referenceId),
                    _buildDetailRow('Description', description),
                  ],
                ),
              ),
              const SizedBox(height: Constants.marginLarge),
              // Actions
              if (status.toLowerCase() == 'failed' || status.toLowerCase() == 'declined' || status.toLowerCase() == 'expired') ...[
                AppButton(
                  text: 'Try Again',
                  onPressed: () {
                    // Navigate to payment screen with pre-filled data
                  },
                  icon: Icons.refresh,
                  isFullWidth: true,
                ),
                const SizedBox(height: Constants.marginMedium),
              ],
              AppButton(
                text: 'Download Receipt',
                type: ButtonType.outline,
                onPressed: status.toLowerCase() == 'success' || status.toLowerCase() == 'completed' || status.toLowerCase() == 'paid'
                    ? () {
                        // Download receipt
                      }
                    : null,
                icon: Icons.download,
                isFullWidth: true,
              ),
              const SizedBox(height: Constants.marginMedium),
              AppButton(
                text: 'Contact Support',
                type: ButtonType.text,
                onPressed: () {
                  // Contact support
                },
                icon: Icons.support_agent,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: Constants.paddingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'paid':
        return 'Your payment has been successfully processed.';
      case 'pending':
        return 'Your payment is being processed. Please wait.';
      case 'processing':
        return 'Your payment is being processed by the payment gateway.';
      case 'failed':
        return 'Your payment has failed. Please try again.';
      case 'declined':
        return 'Your payment was declined by the payment gateway.';
      case 'expired':
        return 'Your payment session has expired.';
      case 'canceled':
        return 'Your payment was canceled.';
      default:
        return 'Unknown payment status.';
    }
  }
}