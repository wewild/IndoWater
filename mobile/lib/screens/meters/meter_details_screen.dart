import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/consumption_chart.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class MeterDetailsScreen extends StatefulWidget {
  final String meterId;

  const MeterDetailsScreen({
    Key? key,
    required this.meterId,
  }) : super(key: key);

  @override
  State<MeterDetailsScreen> createState() => _MeterDetailsScreenState();
}

class _MeterDetailsScreenState extends State<MeterDetailsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _meterDetails;
  List<Map<String, dynamic>> _consumptionHistory = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  late TabController _tabController;
  ChartPeriod _selectedPeriod = ChartPeriod.monthly;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMeterDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMeterDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      
      // Get meter details
      final meterDetails = await meterService.getMeterDetails(widget.meterId);
      
      // Get consumption history
      final consumptionHistory = await meterService.getMeterConsumptionHistory(widget.meterId);
      
      // Get payment history
      final paymentHistory = await meterService.getMeterPaymentHistory(widget.meterId);

      if (!mounted) return;

      setState(() {
        _meterDetails = meterDetails;
        _consumptionHistory = consumptionHistory;
        _paymentHistory = paymentHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ConsumptionData> _getConsumptionData() {
    if (_consumptionHistory.isEmpty) {
      return [];
    }
    
    // Convert consumption history to chart data
    return _consumptionHistory.map((item) {
      final date = DateTime.parse(item['date']);
      return ConsumptionData(
        label: '${date.day}/${date.month}',
        value: item['value'] ?? 0.0,
        date: date,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppTopBar(title: 'Meter Details'),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppTopBar(title: 'Meter Details'),
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
                'Error loading meter details',
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
                onPressed: _loadMeterDetails,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      );
    }
    
    if (_meterDetails == null) {
      return Scaffold(
        appBar: AppTopBar(title: 'Meter Details'),
        body: Center(
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
                'Meter not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Constants.marginSmall),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                child: Text(
                  'The meter you are looking for does not exist or has been removed.',
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
    
    // Format meter data
    final meterNumber = _meterDetails!['meter_number'];
    final nickname = _meterDetails!['nickname'] ?? 'My Meter';
    final address = _meterDetails!['address'] ?? 'No address';
    final status = _meterDetails!['status'] ?? 'active';
    final balance = _meterDetails!['balance'] ?? 0.0;
    final lastReading = _meterDetails!['last_reading'] ?? 0.0;
    final lastReadingDate = _meterDetails!['last_reading_date'] != null
        ? DateTime.parse(_meterDetails!['last_reading_date'])
        : DateTime.now();
    final formattedBalance = '${Constants.currencySymbol} ${balance.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}';
    final formattedLastReading = '${lastReading.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
    final formattedLastReadingDate = '${lastReadingDate.day}/${lastReadingDate.month}/${lastReadingDate.year}';
    final isLowBalance = balance <= Constants.lowBalanceThreshold;
    
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(
        title: nickname,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit meter screen
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Constants.waterError),
                    SizedBox(width: Constants.marginSmall),
                    Text('Delete Meter'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMeterDetails,
        color: theme.primaryColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Constants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meter info card
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
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
                                        'Meter Number',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        meterNumber,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Constants.marginLarge),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    text: 'Top Up',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.topup,
                                        arguments: {'meter_id': widget.meterId},
                                      );
                                    },
                                    icon: Icons.add,
                                    size: ButtonSize.small,
                                  ),
                                ),
                                const SizedBox(width: Constants.marginMedium),
                                Expanded(
                                  child: AppButton(
                                    text: 'Submit Reading',
                                    type: ButtonType.outline,
                                    onPressed: () {
                                      // Navigate to submit reading screen
                                    },
                                    icon: Icons.camera_alt,
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
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  AppTabBar(
                    tabController: _tabController,
                    tabs: const ['Overview', 'Consumption', 'Payments'],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // Overview tab
              _buildOverviewTab(),
              
              // Consumption tab
              _buildConsumptionTab(),
              
              // Payments tab
              _buildPaymentsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    final consumptionData = _getConsumptionData();
    
    return ListView(
      padding: const EdgeInsets.all(Constants.paddingMedium),
      children: [
        // Consumption chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardHeader(
                title: 'Consumption Overview',
                subtitle: 'Last 30 days',
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.consumptionHistory,
                      arguments: {'meter_id': widget.meterId},
                    );
                  },
                ),
              ),
              consumptionData.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart,
                              size: 48,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: Constants.marginMedium),
                            Text(
                              'No consumption data available',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ConsumptionChart(
                      data: consumptionData,
                      period: ChartPeriod.monthly,
                      title: '',
                      subtitle: '',
                      maxY: 50,
                      height: 200,
                    ),
            ],
          ),
        ),
        const SizedBox(height: Constants.marginMedium),
        // Quick stats
        Row(
          children: [
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avg. Daily',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: Constants.iconSizeSmall,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '3.2 ${Constants.volumeUnit}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: Constants.marginMedium),
            Expanded(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: Constants.marginSmall),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: Constants.iconSizeSmall,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '78.5 ${Constants.volumeUnit}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Constants.marginMedium),
        // Recent payments
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardHeader(
                title: 'Recent Payments',
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.paymentHistory,
                      arguments: {'meter_id': widget.meterId},
                    );
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              _paymentHistory.isEmpty
                  ? SizedBox(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 32,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: Constants.marginSmall),
                            Text(
                              'No payment history',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _paymentHistory.length > 3 ? 3 : _paymentHistory.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: Constants.dividerThickness,
                        color: theme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final payment = _paymentHistory[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                            ),
                            child: Icon(
                              Icons.receipt,
                              color: theme.primaryColor,
                            ),
                          ),
                          title: Text(
                            payment['title'] ?? 'Payment',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            payment['date'] != null
                                ? '${DateTime.parse(payment['date']).day}/${DateTime.parse(payment['date']).month}/${DateTime.parse(payment['date']).year}'
                                : '',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            '${Constants.currencySymbol} ${(payment['amount'] ?? 0.0).toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.paymentDetails,
                              arguments: {'payment_id': payment['id'].toString()},
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionTab() {
    final theme = Theme.of(context);
    final consumptionData = _getConsumptionData();
    
    return ListView(
      padding: const EdgeInsets.all(Constants.paddingMedium),
      children: [
        // Period selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPeriodButton('Daily', ChartPeriod.daily),
            _buildPeriodButton('Weekly', ChartPeriod.weekly),
            _buildPeriodButton('Monthly', ChartPeriod.monthly),
            _buildPeriodButton('Yearly', ChartPeriod.yearly),
          ],
        ),
        const SizedBox(height: Constants.marginLarge),
        // Consumption chart
        AppCard(
          child: consumptionData.isEmpty
              ? SizedBox(
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 64,
                          color: theme.hintColor,
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        Text(
                          'No consumption data available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Constants.marginSmall),
                        Text(
                          'Consumption data will appear here once available',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ConsumptionChart(
                  data: consumptionData,
                  period: _selectedPeriod,
                  title: 'Water Consumption',
                  subtitle: 'Based on meter readings',
                  maxY: 50,
                  height: 300,
                ),
        ),
        const SizedBox(height: Constants.marginLarge),
        // Consumption history
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardHeader(
                title: 'Consumption History',
                trailing: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                ),
              ),
              _consumptionHistory.isEmpty
                  ? SizedBox(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 32,
                              color: theme.hintColor,
                            ),
                            const SizedBox(height: Constants.marginSmall),
                            Text(
                              'No consumption history',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _consumptionHistory.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: Constants.dividerThickness,
                        color: theme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final consumption = _consumptionHistory[index];
                        final date = DateTime.parse(consumption['date']);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${date.day}/${date.month}/${date.year}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Reading: ${consumption['reading'] ?? 0.0} ${Constants.volumeUnit}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            '${consumption['value'] ?? 0.0} ${Constants.volumeUnit}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentsTab() {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(Constants.paddingMedium),
      children: [
        // Payment actions
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'Top Up',
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.topup,
                    arguments: {'meter_id': widget.meterId},
                  );
                },
                icon: Icons.add,
              ),
            ),
            const SizedBox(width: Constants.marginMedium),
            Expanded(
              child: AppButton(
                text: 'Pay Bill',
                type: ButtonType.outline,
                onPressed: () {
                  // Navigate to pay bill screen
                },
                icon: Icons.receipt,
              ),
            ),
          ],
        ),
        const SizedBox(height: Constants.marginLarge),
        // Payment history
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCardHeader(
                title: 'Payment History',
                trailing: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Show filter options
                  },
                ),
              ),
              _paymentHistory.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
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
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _paymentHistory.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: Constants.dividerThickness,
                        color: theme.dividerColor,
                      ),
                      itemBuilder: (context, index) {
                        final payment = _paymentHistory[index];
                        final date = DateTime.parse(payment['date'] ?? DateTime.now().toIso8601String());
                        
                        // Determine status color
                        Color statusColor;
                        IconData statusIcon;
                        final status = payment['status'] ?? 'pending';
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
                        
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                            ),
                            child: Icon(
                              statusIcon,
                              color: statusColor,
                            ),
                          ),
                          title: Text(
                            payment['title'] ?? 'Payment',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${date.day}/${date.month}/${date.year} • ${status.toUpperCase()}',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Text(
                            '${Constants.currencySymbol} ${(payment['amount'] ?? 0.0).toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.paymentDetails,
                              arguments: {'payment_id': payment['id'].toString()},
                            );
                          },
                        );
                      },
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(String label, ChartPeriod period) {
    final theme = Theme.of(context);
    final isSelected = _selectedPeriod == period;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = period;
            });
          }
        },
        backgroundColor: theme.cardColor,
        selectedColor: theme.primaryColor.withOpacity(0.2),
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final theme = Theme.of(context);
    
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Meter'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Are you sure you want to delete this meter?'),
                const SizedBox(height: Constants.marginSmall),
                Text(
                  'This action cannot be undone and all associated data will be lost.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteMeter();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMeter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      final success = await meterService.deleteMeter(widget.meterId);

      if (!mounted) return;

      if (success) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meter deleted successfully'),
            backgroundColor: Constants.waterSuccess,
          ),
        );
        
        // Navigate back to meters screen
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = 'Failed to delete meter. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  double get minExtent => child.preferredSize.height;
  
  @override
  double get maxExtent => child.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}