import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';

class TopupConfirmationScreen extends StatefulWidget {
  final double amount;
  final String paymentId;
  final String status;

  const TopupConfirmationScreen({
    Key? key,
    required this.amount,
    required this.paymentId,
    required this.status,
  }) : super(key: key);

  @override
  State<TopupConfirmationScreen> createState() => _TopupConfirmationScreenState();
}

class _TopupConfirmationScreenState extends State<TopupConfirmationScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  String _status = '';
  Timer? _statusCheckTimer;
  int _countdown = 300; // 5 minutes countdown

  @override
  void initState() {
    super.initState();
    _status = widget.status;
    _startStatusCheck();
    _startCountdown();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck() {
    // Check payment status every 5 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkPaymentStatus();
    });
  }

  void _startCountdown() {
    // Update countdown every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final paymentDetails = await paymentService.getPaymentDetails(widget.paymentId);

      if (!mounted) return;

      final status = paymentDetails['status'] ?? 'pending';
      
      setState(() {
        _status = status;
        _isLoading = false;
      });

      // If payment is completed or failed, navigate to the appropriate screen
      if (status.toLowerCase() == 'success' || 
          status.toLowerCase() == 'completed' || 
          status.toLowerCase() == 'paid') {
        _statusCheckTimer?.cancel();
        
        // Navigate to success screen
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.topupSuccess,
          arguments: {
            'amount': widget.amount,
            'payment_id': widget.paymentId,
          },
        );
      } else if (status.toLowerCase() == 'failed' || 
                status.toLowerCase() == 'declined' || 
                status.toLowerCase() == 'expired' ||
                status.toLowerCase() == 'canceled') {
        _statusCheckTimer?.cancel();
        
        // Navigate to failed screen
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.topupFailed,
          arguments: {
            'amount': widget.amount,
            'error': 'Payment ${status.toLowerCase()}',
          },
        );
      }
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingLarge),
          child: Column(
            children: [
              const Spacer(),
              // Pending icon
              Icon(
                Icons.access_time,
                size: 100,
                color: Constants.waterWarning,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Pending message
              Text(
                'Payment Processing',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Constants.waterWarning,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginMedium),
              Text(
                'Your payment is being processed. Please complete the payment within the time limit.',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginLarge),
              // Countdown
              AppCard(
                child: Column(
                  children: [
                    Text(
                      'Time Remaining',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Text(
                      _formatCountdown(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _countdown < 60 ? Constants.waterError : Constants.waterWarning,
                      ),
                    ),
                    const SizedBox(height: Constants.marginMedium),
                    LinearProgressIndicator(
                      value: _countdown / 300, // Progress from 0 to 1
                      backgroundColor: theme.dividerColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _countdown < 60 ? Constants.waterError : Constants.waterWarning,
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
                      'Amount',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Text(
                      '${Constants.currencySymbol} ${widget.amount.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
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
                          widget.paymentId,
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
                          'Status',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Constants.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Constants.waterWarning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                          ),
                          child: Text(
                            _status.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Constants.waterWarning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Error message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(Constants.paddingMedium),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: Constants.marginSmall),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Constants.marginLarge),
              ],
              // Buttons
              AppButton(
                text: 'Check Status',
                onPressed: _isLoading ? null : _checkPaymentStatus,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
              const SizedBox(height: Constants.marginMedium),
              AppButton(
                text: 'Cancel Payment',
                type: ButtonType.outline,
                onPressed: () {
                  _statusCheckTimer?.cancel();
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

  String _formatCountdown() {
    final minutes = (_countdown / 60).floor();
    final seconds = _countdown % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}