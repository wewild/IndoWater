import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/payment_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _paymentHistory = [];
  List<Map<String, dynamic>> _meters = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final meterService = Provider.of<MeterService>(context, listen: false);
      
      // Get payment history
      final paymentHistory = await paymentService.getPaymentHistory();
      
      // Get user meters
      final meters = await meterService.getUserMeters();

      if (!mounted) return;

      setState(() {
        _paymentHistory = paymentHistory;
        _meters = meters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredPayments(String filter) {
    if (_paymentHistory.isEmpty) {
      return [];
    }
    
    switch (filter) {
      case 'topup':
        return _paymentHistory.where((payment) => payment['type'] == 'topup').toList();
      case 'bill':
        return _paymentHistory.where((payment) => payment['type'] == 'bill').toList();
      default:
        return _paymentHistory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: 'Payments',
        bottom: AppTabBar(
          tabController: _tabController,
          tabs: const ['All', 'Top-ups', 'Bills'],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
          : _errorMessage != null
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
                        'Error loading payments',
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
                        onPressed: _loadData,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // All payments tab
                    _buildPaymentsList(_getFilteredPayments('all')),
                    
                    // Top-ups tab
                    _buildPaymentsList(_getFilteredPayments('topup')),
                    
                    // Bills tab
                    _buildPaymentsList(_getFilteredPayments('bill')),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.topup);
        },
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Top Up'),
      ),
    );
  }

  Widget _buildPaymentsList(List<Map<String, dynamic>> payments) {
    final theme = Theme.of(context);
    
    if (payments.isEmpty) {
      return Center(
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
              'No payment history',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.marginSmall),
            Text(
              'Your payment history will appear here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.marginLarge),
            AppButton(
              text: 'Make a Payment',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.topup);
              },
              icon: Icons.add,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: theme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(Constants.paddingMedium),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          return PaymentCard(
            paymentId: payment['id'].toString(),
            title: payment['title'] ?? 'Payment',
            description: payment['description'] ?? 'Payment transaction',
            amount: payment['amount'] ?? 0.0,
            date: payment['date'] != null
                ? DateTime.parse(payment['date'])
                : DateTime.now(),
            status: payment['status'] ?? 'pending',
            paymentMethod: payment['payment_method'],
            meterNumber: payment['meter_number'],
            type: payment['type'] == 'topup'
                ? PaymentCardType.topup
                : PaymentCardType.history,
            onTap: () {
              Navigator.of(context).pushNamed(
                AppRoutes.paymentDetails,
                arguments: {'payment_id': payment['id'].toString()},
              );
            },
            onViewDetails: () {
              Navigator.of(context).pushNamed(
                AppRoutes.paymentDetails,
                arguments: {'payment_id': payment['id'].toString()},
              );
            },
          );
        },
      ),
    );
  }
}