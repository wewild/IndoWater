import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/consumption_chart.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class ConsumptionScreen extends StatefulWidget {
  const ConsumptionScreen({Key? key}) : super(key: key);

  @override
  State<ConsumptionScreen> createState() => _ConsumptionScreenState();
}

class _ConsumptionScreenState extends State<ConsumptionScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _meters = [];
  Map<String, List<Map<String, dynamic>>> _consumptionData = {};
  String? _selectedMeterId;
  ChartPeriod _selectedPeriod = ChartPeriod.monthly;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      
      // Get user meters
      final meters = await meterService.getUserMeters();
      
      // If there are meters, select the first one by default
      String? selectedMeterId;
      if (meters.isNotEmpty) {
        selectedMeterId = meters.first['id'].toString();
      }
      
      // Get consumption data for each meter
      final Map<String, List<Map<String, dynamic>>> consumptionData = {};
      for (final meter in meters) {
        final meterId = meter['id'].toString();
        final meterConsumption = await meterService.getMeterConsumptionHistory(meterId);
        consumptionData[meterId] = meterConsumption;
      }

      if (!mounted) return;

      setState(() {
        _meters = meters;
        _consumptionData = consumptionData;
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

  List<ConsumptionData> _getConsumptionData() {
    if (_selectedMeterId == null || !_consumptionData.containsKey(_selectedMeterId)) {
      return [];
    }
    
    final meterConsumption = _consumptionData[_selectedMeterId]!;
    if (meterConsumption.isEmpty) {
      return [];
    }
    
    // Convert consumption history to chart data
    return meterConsumption.map((item) {
      final date = DateTime.parse(item['date']);
      return ConsumptionData(
        label: '${date.day}/${date.month}',
        value: item['value'] ?? 0.0,
        date: date,
      );
    }).toList();
  }

  void _selectMeter(String meterId) {
    setState(() {
      _selectedMeterId = meterId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Water Consumption'),
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
                        'Error loading consumption data',
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
                              'Add a meter to start tracking your water consumption',
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
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: theme.primaryColor,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Meter selector
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
                              // Period selector
                              Text(
                                'Time Period',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: Constants.marginMedium),
                              Row(
                                children: [
                                  _buildPeriodButton('Daily', ChartPeriod.daily),
                                  const SizedBox(width: Constants.marginSmall),
                                  _buildPeriodButton('Weekly', ChartPeriod.weekly),
                                  const SizedBox(width: Constants.marginSmall),
                                  _buildPeriodButton('Monthly', ChartPeriod.monthly),
                                  const SizedBox(width: Constants.marginSmall),
                                  _buildPeriodButton('Yearly', ChartPeriod.yearly),
                                ],
                              ),
                              const SizedBox(height: Constants.marginLarge),
                              // Consumption chart
                              AppCard(
                                child: _selectedMeterId == null
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
                                                'No meter selected',
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: Constants.marginSmall),
                                              Text(
                                                'Please select a meter to view consumption data',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : _getConsumptionData().isEmpty
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
                                            data: _getConsumptionData(),
                                            period: _selectedPeriod,
                                            title: 'Water Consumption',
                                            subtitle: _getChartSubtitle(),
                                            maxY: 50,
                                            height: 300,
                                          ),
                              ),
                              const SizedBox(height: Constants.marginLarge),
                              // Consumption stats
                              if (_selectedMeterId != null && _getConsumptionData().isNotEmpty) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'Total',
                                        value: _calculateTotal(),
                                        icon: Icons.water_drop,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: Constants.marginMedium),
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'Average',
                                        value: _calculateAverage(),
                                        icon: Icons.show_chart,
                                        color: Constants.waterSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Constants.marginMedium),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'Highest',
                                        value: _calculateHighest(),
                                        icon: Icons.arrow_upward,
                                        color: Constants.waterWarning,
                                      ),
                                    ),
                                    const SizedBox(width: Constants.marginMedium),
                                    Expanded(
                                      child: _buildStatCard(
                                        title: 'Lowest',
                                        value: _calculateLowest(),
                                        icon: Icons.arrow_downward,
                                        color: Constants.waterInfo,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: Constants.marginLarge),
                              // View history button
                              if (_selectedMeterId != null)
                                AppButton(
                                  text: 'View Detailed History',
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.consumptionHistory,
                                      arguments: {'meter_id': _selectedMeterId},
                                    );
                                  },
                                  icon: Icons.history,
                                  isFullWidth: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildPeriodButton(String label, ChartPeriod period) {
    final theme = Theme.of(context);
    final isSelected = _selectedPeriod == period;
    
    return Expanded(
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: Constants.iconSizeSmall,
                ),
              ),
              const SizedBox(width: Constants.marginSmall),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.marginMedium),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getChartSubtitle() {
    switch (_selectedPeriod) {
      case ChartPeriod.daily:
        return 'Last 24 hours';
      case ChartPeriod.weekly:
        return 'Last 7 days';
      case ChartPeriod.monthly:
        return 'Last 30 days';
      case ChartPeriod.yearly:
        return 'Last 12 months';
    }
  }

  String _calculateTotal() {
    final data = _getConsumptionData();
    if (data.isEmpty) return '0 ${Constants.volumeUnit}';
    
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    return '${total.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
  }

  String _calculateAverage() {
    final data = _getConsumptionData();
    if (data.isEmpty) return '0 ${Constants.volumeUnit}';
    
    final total = data.fold<double>(0, (sum, item) => sum + item.value);
    final average = total / data.length;
    return '${average.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
  }

  String _calculateHighest() {
    final data = _getConsumptionData();
    if (data.isEmpty) return '0 ${Constants.volumeUnit}';
    
    final highest = data.map((item) => item.value).reduce((a, b) => a > b ? a : b);
    return '${highest.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
  }

  String _calculateLowest() {
    final data = _getConsumptionData();
    if (data.isEmpty) return '0 ${Constants.volumeUnit}';
    
    final lowest = data.map((item) => item.value).reduce((a, b) => a < b ? a : b);
    return '${lowest.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
  }
}