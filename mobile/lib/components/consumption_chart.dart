import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:indowater_mobile/utils/constants.dart';

enum ChartPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

class ConsumptionChart extends StatelessWidget {
  final List<ConsumptionData> data;
  final ChartPeriod period;
  final String title;
  final String subtitle;
  final double maxY;
  final double minY;
  final bool showAverage;
  final bool showGrid;
  final bool showBorder;
  final double height;
  final Color? barColor;
  final Color? averageLineColor;
  final Color? gridColor;
  final Color? borderColor;
  final Color? textColor;

  const ConsumptionChart({
    Key? key,
    required this.data,
    this.period = ChartPeriod.monthly,
    this.title = 'Water Consumption',
    this.subtitle = '',
    this.maxY = 100,
    this.minY = 0,
    this.showAverage = true,
    this.showGrid = true,
    this.showBorder = true,
    this.height = 300,
    this.barColor,
    this.averageLineColor,
    this.gridColor,
    this.borderColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate average consumption
    final average = data.isEmpty
        ? 0.0
        : data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
    
    // Format average consumption
    final formattedAverage = '${average.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}';
    
    // Determine x-axis label based on period
    String Function(double) getBottomTitles;
    switch (period) {
      case ChartPeriod.daily:
        getBottomTitles = (value) => '${value.toInt()}h';
        break;
      case ChartPeriod.weekly:
        getBottomTitles = (value) {
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final index = value.toInt();
          if (index >= 0 && index < days.length) {
            return days[index];
          }
          return '';
        };
        break;
      case ChartPeriod.monthly:
        getBottomTitles = (value) => '${value.toInt() + 1}';
        break;
      case ChartPeriod.yearly:
        getBottomTitles = (value) {
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          final index = value.toInt();
          if (index >= 0 && index < months.length) {
            return months[index];
          }
          return '';
        };
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Constants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor?.withOpacity(0.7) ?? theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
              if (showAverage) ...[
                const SizedBox(height: Constants.marginMedium),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: averageLineColor ?? theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Average: $formattedAverage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor?.withOpacity(0.7) ?? theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Constants.marginMedium),
        // Chart
        SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(
              right: Constants.paddingMedium,
              left: Constants.paddingSmall,
              bottom: Constants.paddingMedium,
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: minY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.cardColor,
                    tooltipPadding: const EdgeInsets.all(Constants.paddingSmall),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data[groupIndex].label}: ${rod.toY.toStringAsFixed(Constants.decimalPlaces).replaceAll('.', Constants.decimalSeparator)} ${Constants.volumeUnit}',
                        theme.textTheme.bodySmall!,
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            getBottomTitles(value),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor?.withOpacity(0.7) ?? theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor?.withOpacity(0.7) ?? theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: showGrid,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridColor ?? theme.dividerColor.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: gridColor ?? theme.dividerColor.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: showBorder,
                  border: Border(
                    bottom: BorderSide(
                      color: borderColor ?? theme.dividerColor,
                      width: 1,
                    ),
                    left: BorderSide(
                      color: borderColor ?? theme.dividerColor,
                      width: 1,
                    ),
                    right: BorderSide(
                      color: borderColor ?? Colors.transparent,
                      width: 1,
                    ),
                    top: BorderSide(
                      color: borderColor ?? Colors.transparent,
                      width: 1,
                    ),
                  ),
                ),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: item.value,
                        color: barColor ?? theme.primaryColor,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Constants.borderRadiusSmall),
                          topRight: Radius.circular(Constants.borderRadiusSmall),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                extraLinesData: showAverage
                    ? ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: average,
                            color: averageLineColor ?? theme.colorScheme.secondary,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ConsumptionData {
  final String label;
  final double value;
  final DateTime date;

  ConsumptionData({
    required this.label,
    required this.value,
    required this.date,
  });
}