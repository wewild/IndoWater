import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/services/payment_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/meter_card.dart';
import 'package:indowater_mobile/components/payment_card.dart';
import 'package:indowater_mobile/components/consumption_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _meters = [];
  List<Map<String, dynamic>> _recentPayments = [];
  List<ConsumptionData> _consumptionData = [];
  double _totalBalance = 0;
  String? _userName;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user info
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.getCurrentUser();
      
      if (user != null) {
        setState(() {
          _userName = user.name;
        });
      }

      // Get meters
      final meterService = Provider.of<MeterService>(context, listen: false);
      final meters = await meterService.getUserMeters();
      
      // Calculate total balance
      double totalBalance = 0;
      for (final meter in meters) {
        totalBalance += meter['balance'] as double;
      }

      // Get recent payments
      final paymentService = Provider.of<PaymentService>(context, listen: false);
      final payments = await paymentService.getPaymentHistory();
      
      // Get consumption data for chart (mock data for now)
      final consumptionData = _generateMockConsumptionData();

      if (!mounted) return;

      setState(() {
        _meters = meters;
        _recentPayments = payments.take(3).toList(); // Only show 3 most recent payments
        _consumptionData = consumptionData;
        _totalBalance = totalBalance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ConsumptionData> _generateMockConsumptionData() {
    // Generate mock consumption data for the last 7 days
    final now = DateTime.now();
    final List<ConsumptionData> data = [];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final value = 10 + (20 * i / 6) + (10 * (i % 3)); // Random-ish values between 10 and 40
      
      data.add(ConsumptionData(
        label: '${date.day}/${date.month}',
        value: value,
        date: date,
      ));
    }
    
    return data;
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
    
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.meters);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRoutes.consumption);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.payments);
        break;
      case 4:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.notifications);
            },
          ),
        ],
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
                        'Error loading dashboard',
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
                        onPressed: _loadDashboardData,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  color: theme.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with balance
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(Constants.paddingLarge),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(Constants.borderRadiusLarge),
                              bottomRight: Radius.circular(Constants.borderRadiusLarge),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting
                              Text(
                                'Hello, ${_userName ?? 'User'}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: Constants.marginSmall),
                              Text(
                                'Welcome to IndoWater',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: Constants.marginLarge),
                              // Total balance card
                              Container(
                                padding: const EdgeInsets.all(Constants.paddingMedium),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total Balance',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: Constants.paddingSmall,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _totalBalance <= Constants.lowBalanceThreshold
                                                ? Constants.waterError.withOpacity(0.1)
                                                : Constants.waterSuccess.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                                          ),
                                          child: Text(
                                            _totalBalance <= Constants.lowBalanceThreshold ? 'LOW BALANCE' : 'ACTIVE',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: _totalBalance <= Constants.lowBalanceThreshold
                                                  ? Constants.waterError
                                                  : Constants.waterSuccess,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: Constants.marginMedium),
                                    Text(
                                      '${Constants.currencySymbol} ${_totalBalance.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _totalBalance <= Constants.lowBalanceThreshold
                                            ? Constants.waterError
                                            : theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: Constants.marginMedium),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: AppButton(
                                            text: 'Top Up',
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(AppRoutes.topup);
                                            },
                                            icon: Icons.add,
                                            size: ButtonSize.small,
                                          ),
                                        ),
                                        const SizedBox(width: Constants.marginMedium),
                                        Expanded(
                                          child: AppButton(
                                            text: 'History',
                                            type: ButtonType.outline,
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(AppRoutes.payments);
                                            },
                                            icon: Icons.history,
                                            size: ButtonSize.small,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Quick actions
                        Padding(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Actions',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: Constants.marginMedium),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildQuickActionItem(
                                    icon: Icons.qr_code_scanner,
                                    label: 'Scan QR',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRoutes.addMeter);
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: Icons.water_drop,
                                    label: 'Add Meter',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRoutes.addMeter);
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: Icons.receipt,
                                    label: 'Pay Bill',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRoutes.payments);
                                    },
                                  ),
                                  _buildQuickActionItem(
                                    icon: Icons.history,
                                    label: 'History',
                                    onTap: () {
                                      Navigator.of(context).pushNamed(AppRoutes.consumptionHistory);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // My meters
                        Padding(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'My Meters',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(AppRoutes.meters);
                                    },
                                    child: Text(
                                      'View All',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Constants.marginSmall),
                              _meters.isEmpty
                                  ? AppCard(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.water_drop_outlined,
                                            size: 48,
                                            color: theme.hintColor,
                                          ),
                                          const SizedBox(height: Constants.marginMedium),
                                          Text(
                                            'No meters found',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: Constants.marginSmall),
                                          Text(
                                            'Add your first meter to start monitoring your water consumption',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: Constants.marginMedium),
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
                                  : Column(
                                      children: _meters.take(2).map((meter) {
                                        return MeterCard(
                                          meterId: meter['id'].toString(),
                                          meterNumber: meter['meter_number'],
                                          nickname: meter['nickname'] ?? 'My Meter',
                                          address: meter['address'] ?? 'No address',
                                          status: meter['status'] ?? 'active',
                                          balance: meter['balance'] ?? 0.0,
                                          lastReading: meter['last_reading'] ?? 0.0,
                                          lastReadingDate: meter['last_reading_date'] != null
                                              ? DateTime.parse(meter['last_reading_date'])
                                              : DateTime.now(),
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.meterDetails,
                                              arguments: {'meter_id': meter['id'].toString()},
                                            );
                                          },
                                          onViewDetails: () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.meterDetails,
                                              arguments: {'meter_id': meter['id'].toString()},
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                        // Consumption chart
                        Padding(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          child: AppCard(
                            child: ConsumptionChart(
                              data: _consumptionData,
                              period: ChartPeriod.weekly,
                              title: 'Weekly Consumption',
                              subtitle: 'Last 7 days',
                              maxY: 50,
                              height: 250,
                            ),
                          ),
                        ),
                        // Recent payments
                        Padding(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Recent Payments',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(AppRoutes.paymentHistory);
                                    },
                                    child: Text(
                                      'View All',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Constants.marginSmall),
                              _recentPayments.isEmpty
                                  ? AppCard(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.receipt_outlined,
                                            size: 48,
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
                                        ],
                                      ),
                                    )
                                  : Column(
                                      children: _recentPayments.map((payment) {
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
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                        // Bottom padding
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: _navigateToScreen,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.cardColor,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: theme.hintColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: 'Meters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Usage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.addMeter);
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: Constants.iconSizeLarge,
            ),
          ),
          const SizedBox(height: Constants.marginSmall),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}