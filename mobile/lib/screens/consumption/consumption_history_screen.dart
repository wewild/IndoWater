import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class ConsumptionHistoryScreen extends StatefulWidget {
  final String? meterId;

  const ConsumptionHistoryScreen({
    Key? key,
    this.meterId,
  }) : super(key: key);

  @override
  State<ConsumptionHistoryScreen> createState() => _ConsumptionHistoryScreenState();
}

class _ConsumptionHistoryScreenState extends State<ConsumptionHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _meters = [];
  Map<String, List<Map<String, dynamic>>> _consumptionData = {};
  String? _selectedMeterId;
  String? _selectedFilter = 'all';
  final List<String> _filterOptions = ['all', 'week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    _selectedMeterId = widget.meterId;
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
      
      // If no meter is selected and there are meters, select the first one
      String? selectedMeterId = _selectedMeterId;
      if (selectedMeterId == null && meters.isNotEmpty) {
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

  List<Map<String, dynamic>> _getFilteredConsumptionData() {
    if (_selectedMeterId == null || !_consumptionData.containsKey(_selectedMeterId)) {
      return [];
    }
    
    final meterConsumption = _consumptionData[_selectedMeterId]!;
    if (meterConsumption.isEmpty) {
      return [];
    }
    
    if (_selectedFilter == 'all') {
      return meterConsumption;
    }
    
    final now = DateTime.now();
    DateTime cutoffDate;
    
    switch (_selectedFilter) {
      case 'week':
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        cutoffDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        cutoffDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        return meterConsumption;
    }
    
    return meterConsumption.where((item) {
      final date = DateTime.parse(item['date']);
      return date.isAfter(cutoffDate);
    }).toList();
  }

  void _selectMeter(String meterId) {
    setState(() {
      _selectedMeterId = meterId;
    });
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'all':
        return 'All Time';
      case 'week':
        return 'Last Week';
      case 'month':
        return 'Last Month';
      case 'year':
        return 'Last Year';
      default:
        return 'All Time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Consumption History'),
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
                        'Error loading consumption history',
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
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: theme.primaryColor,
                      child: Column(
                        children: [
                          // Filters
                          Padding(
                            padding: const EdgeInsets.all(Constants.paddingMedium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Meter selector
                                if (_meters.length > 1) ...[
                                  Text(
                                    'Select Meter',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: Constants.marginSmall),
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
                                            labelStyle: theme.textTheme.bodySmall?.copyWith(
                                              color: isSelected ? theme.primaryColor : theme.textTheme.bodySmall?.color,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: Constants.marginMedium),
                                ],
                                // Time filter
                                Text(
                                  'Time Period',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: Constants.marginSmall),
                                SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _filterOptions.length,
                                    itemBuilder: (context, index) {
                                      final filter = _filterOptions[index];
                                      final isSelected = _selectedFilter == filter;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(right: Constants.paddingSmall),
                                        child: ChoiceChip(
                                          label: Text(_getFilterLabel(filter)),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            if (selected) {
                                              _selectFilter(filter);
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider
                          Divider(
                            height: 1,
                            thickness: Constants.dividerThickness,
                            color: theme.dividerColor,
                          ),
                          // Consumption history list
                          Expanded(
                            child: _selectedMeterId == null
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
                                          'No meter selected',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: Constants.marginSmall),
                                        Text(
                                          'Please select a meter to view consumption history',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : _getFilteredConsumptionData().isEmpty
                                    ? Center(
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
                                      )
                                    : ListView.separated(
                                        padding: const EdgeInsets.all(Constants.paddingMedium),
                                        itemCount: _getFilteredConsumptionData().length,
                                        separatorBuilder: (context, index) => const SizedBox(height: Constants.marginSmall),
                                        itemBuilder: (context, index) {
                                          final consumption = _getFilteredConsumptionData()[index];
                                          final date = DateTime.parse(consumption['date']);
                                          final formattedDate = '${date.day}/${date.month}/${date.year}';
                                          final reading = consumption['reading'] ?? 0.0;
                                          final value = consumption['value'] ?? 0.0;
                                          
                                          return AppCard(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                            color: theme.primaryColor.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                                                          ),
                                                          child: Icon(
                                                            Icons.water_drop,
                                                            color: theme.primaryColor,
                                                          ),
                                                        ),
                                                        const SizedBox(width: Constants.marginSmall),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              formattedDate,
                                                              style: theme.textTheme.titleSmall?.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              'Reading: ${reading.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}',
                                                              style: theme.textTheme.bodySmall,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: Constants.paddingSmall,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.primaryColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                                                      ),
                                                      child: Text(
                                                        '${value.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}',
                                                        style: theme.textTheme.titleSmall?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: theme.primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (consumption['notes'] != null) ...[
                                                  const SizedBox(height: Constants.marginSmall),
                                                  Divider(
                                                    height: 1,
                                                    thickness: Constants.dividerThickness,
                                                    color: theme.dividerColor,
                                                  ),
                                                  const SizedBox(height: Constants.marginSmall),
                                                  Text(
                                                    'Notes:',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    consumption['notes'],
                                                    style: theme.textTheme.bodySmall,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}