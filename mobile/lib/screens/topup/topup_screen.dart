import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class TopupScreen extends StatefulWidget {
  final String? meterId;

  const TopupScreen({
    Key? key,
    this.meterId,
  }) : super(key: key);

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _meters = [];
  String? _selectedMeterId;
  int _selectedAmount = Constants.creditDenominations[2]; // Default to the third option
  String _selectedPaymentMethod = 'credit_card'; // Default payment method

  @override
  void initState() {
    super.initState();
    _selectedMeterId = widget.meterId;
    _loadMeters();
  }

  Future<void> _loadMeters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      final meters = await meterService.getUserMeters();

      if (!mounted) return;

      // If no meter is selected and there are meters, select the first one
      String? selectedMeterId = _selectedMeterId;
      if (selectedMeterId == null && meters.isNotEmpty) {
        selectedMeterId = meters.first['id'].toString();
      }

      setState(() {
        _meters = meters;
        _selectedMeterId = selectedMeterId;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _processTopup() async {
    if (_selectedMeterId == null) {
      setState(() {
        _errorMessage = 'Please select a meter';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      
      // Initialize payment gateway
      await paymentService.initializeMidtrans();
      
      // Process topup
      final result = await paymentService.processTopup(
        amount: _selectedAmount.toDouble(),
        paymentMethod: _selectedPaymentMethod,
      );

      if (!mounted) return;

      if (result['status'] == PaymentStatus.success) {
        // Navigate to success screen
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.topupSuccess,
          arguments: {
            'amount': _selectedAmount.toDouble(),
            'payment_id': result['transaction_id'],
          },
        );
      } else if (result['status'] == PaymentStatus.pending) {
        // Navigate to confirmation screen
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.topupConfirmation,
          arguments: {
            'amount': _selectedAmount.toDouble(),
            'payment_id': result['transaction_id'],
            'status': 'pending',
          },
        );
      } else {
        // Navigate to failed screen
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.topupFailed,
          arguments: {
            'amount': _selectedAmount.toDouble(),
            'error': result['error'] ?? 'Payment failed',
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
      });
    }
  }

  void _selectMeter(String meterId) {
    setState(() {
      _selectedMeterId = meterId;
    });
  }

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
    });
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Top Up'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
          : _errorMessage != null && _meters.isEmpty
              ? Center(
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
                        'Error loading meters',
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
                        onPressed: _loadMeters,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                )
              : _meters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 64,
                            color: theme.hintColor,
                          ),
                          const SizedBox(height: Constants.marginMedium),
                          Text(
                            'No meters found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: Constants.marginSmall),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                            child: Text(
                              'Add a meter to top up your balance',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: Constants.marginLarge),
                          AppButton(
                            text: 'Add Meter',
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.addMeter);
                            },
                            icon: Icons.add,
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(Constants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            // Meter selector
                            if (_meters.length > 1) ...[
                              Text(
                                'Select Meter',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: Constants.marginMedium),
                              SizedBox(
                                height: 40,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _meters.length,
                                  itemBuilder: (context, index) {
                                    final meter = _meters[index];
                                    final meterId = meter['id'].toString();
                                    final isSelected = _selectedMeterId == meterId;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(right: Constants.paddingSmall),
                                      child: ChoiceChip(
                                        label: Text(meter['nickname'] ?? 'Meter ${index + 1}'),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            _selectMeter(meterId);
                                          }
                                        },
                                        backgroundColor: theme.cardColor,
                                        selectedColor: theme.primaryColor.withOpacity(0.2),
                                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                                          color: isSelected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: Constants.marginLarge),
                            ],
                            // Selected meter info
                            if (_selectedMeterId != null) ...[
                              AppCard(
                                child: Row(
                                  children: [
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getSelectedMeterNickname(),
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Meter: ${_getSelectedMeterNumber()}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Current Balance',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${Constants.currencySymbol} ${_getSelectedMeterBalance().toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: _getSelectedMeterBalance() <= Constants.lowBalanceThreshold
                                                ? Constants.waterError
                                                : theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Constants.marginLarge),
                            ],
                            // Amount selector
                            Text(
                              'Select Amount',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: Constants.marginMedium),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: Constants.marginSmall,
                                mainAxisSpacing: Constants.marginSmall,
                              ),
                              itemCount: Constants.creditDenominations.length,
                              itemBuilder: (context, index) {
                                final amount = Constants.creditDenominations[index];
                                final isSelected = _selectedAmount == amount;
                                
                                return InkWell(
                                  onTap: () {
                                    _selectAmount(amount);
                                  },
                                  borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.primaryColor.withOpacity(0.2)
                                          : theme.cardColor,
                                      borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.primaryColor
                                            : theme.dividerColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${Constants.currencySymbol} ${amount.toString().replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1${Constants.thousandSeparator}')}',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? theme.primaryColor : theme.textTheme.titleSmall?.color,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: Constants.marginLarge),
                            // Payment method
                            Text(
                              'Payment Method',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: Constants.marginMedium),
                            _buildPaymentMethodCard(
                              'credit_card',
                              'Credit/Debit Card',
                              Icons.credit_card,
                              'Visa, Mastercard, JCB',
                            ),
                            const SizedBox(height: Constants.marginSmall),
                            _buildPaymentMethodCard(
                              'bank_transfer',
                              'Bank Transfer',
                              Icons.account_balance,
                              'BCA, Mandiri, BNI, BRI',
                            ),
                            const SizedBox(height: Constants.marginSmall),
                            _buildPaymentMethodCard(
                              'e_wallet',
                              'E-Wallet',
                              Icons.account_balance_wallet,
                              'GoPay, OVO, DANA, LinkAja',
                            ),
                            const SizedBox(height: Constants.marginLarge),
                            // Summary
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppCardHeader(
                                    title: 'Payment Summary',
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Top-up Amount',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '${Constants.currencySymbol} ${_selectedAmount.toString().replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1${Constants.thousandSeparator}')}',
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
                                        'Admin Fee',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      Text(
                                        '${Constants.currencySymbol} 0',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                                        'Total Payment',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${Constants.currencySymbol} ${_selectedAmount.toString().replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1${Constants.thousandSeparator}')}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: Constants.marginLarge),
                            // Pay button
                            AppButton(
                              text: 'Pay Now',
                              onPressed: _isProcessing ? null : _processTopup,
                              isLoading: _isProcessing,
                              isFullWidth: true,
                              size: ButtonSize.large,
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildPaymentMethodCard(
    String method,
    String title,
    IconData icon,
    String description,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedPaymentMethod == method;
    
    return InkWell(
      onTap: () {
        _selectPaymentMethod(method);
      },
      borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(Constants.paddingMedium),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primaryColor.withOpacity(0.1)
                    : theme.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected ? theme.primaryColor : theme.hintColor,
              ),
            ),
            const SizedBox(width: Constants.marginMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Radio(
              value: method,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value != null) {
                  _selectPaymentMethod(value);
                }
              },
              activeColor: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedMeterNickname() {
    if (_selectedMeterId == null) return '';
    
    final selectedMeter = _meters.firstWhere(
      (meter) => meter['id'].toString() == _selectedMeterId,
      orElse: () => {'nickname': 'Unknown Meter'},
    );
    
    return selectedMeter['nickname'] ?? 'My Meter';
  }

  String _getSelectedMeterNumber() {
    if (_selectedMeterId == null) return '';
    
    final selectedMeter = _meters.firstWhere(
      (meter) => meter['id'].toString() == _selectedMeterId,
      orElse: () => {'meter_number': ''},
    );
    
    return selectedMeter['meter_number'] ?? '';
  }

  double _getSelectedMeterBalance() {
    if (_selectedMeterId == null) return 0.0;
    
    final selectedMeter = _meters.firstWhere(
      (meter) => meter['id'].toString() == _selectedMeterId,
      orElse: () => {'balance': 0.0},
    );
    
    return selectedMeter['balance'] ?? 0.0;
  }
}