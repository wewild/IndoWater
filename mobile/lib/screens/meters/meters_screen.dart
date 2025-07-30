import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/meter_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class MetersScreen extends StatefulWidget {
  const MetersScreen({Key? key}) : super(key: key);

  @override
  State<MetersScreen> createState() => _MetersScreenState();
}

class _MetersScreenState extends State<MetersScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _meters = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredMeters = [];

  @override
  void initState() {
    super.initState();
    _loadMeters();
    _searchController.addListener(_filterMeters);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMeters);
    _searchController.dispose();
    super.dispose();
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

      setState(() {
        _meters = meters;
        _filteredMeters = meters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMeters() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredMeters = _meters;
      });
      return;
    }
    
    setState(() {
      _filteredMeters = _meters.where((meter) {
        final meterNumber = meter['meter_number'].toString().toLowerCase();
        final nickname = (meter['nickname'] ?? '').toString().toLowerCase();
        final address = (meter['address'] ?? '').toString().toLowerCase();
        
        return meterNumber.contains(query) || 
               nickname.contains(query) || 
               address.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _searchController.text.isNotEmpty
          ? AppSearchBar(
              controller: _searchController,
              hintText: 'Search meters...',
              onClear: () {
                setState(() {
                  _filteredMeters = _meters;
                });
              },
            )
          : AppTopBar(
              title: 'My Meters',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      // Show search bar in next build
                      _searchController.text = ' ';
                      _searchController.selection = TextSelection.fromPosition(
                        const TextPosition(offset: 1),
                      );
                    });
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
              : RefreshIndicator(
                  onRefresh: _loadMeters,
                  color: theme.primaryColor,
                  child: _filteredMeters.isEmpty
                      ? _meters.isEmpty
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
                                      'Add your first meter to start monitoring your water consumption',
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
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: theme.hintColor,
                                  ),
                                  const SizedBox(height: Constants.marginMedium),
                                  Text(
                                    'No results found',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: Constants.marginSmall),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                                    child: Text(
                                      'Try a different search term',
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: Constants.marginLarge),
                                  AppButton(
                                    text: 'Clear Search',
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: Icons.clear,
                                  ),
                                ],
                              ),
                            )
                      : ListView.builder(
                          padding: const EdgeInsets.all(Constants.paddingMedium),
                          itemCount: _filteredMeters.length,
                          itemBuilder: (context, index) {
                            final meter = _filteredMeters[index];
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
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.addMeter);
        },
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}