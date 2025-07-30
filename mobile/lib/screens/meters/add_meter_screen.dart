import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/services/meter_service.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_text_field.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';
import 'package:indowater_mobile/components/qr_scanner.dart';
import 'package:form_field_validator/form_field_validator.dart';

class AddMeterScreen extends StatefulWidget {
  const AddMeterScreen({Key? key}) : super(key: key);

  @override
  State<AddMeterScreen> createState() => _AddMeterScreenState();
}

class _AddMeterScreenState extends State<AddMeterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isScanning = false;
  String? _errorMessage;
  bool _isSuccess = false;
  Map<String, dynamic>? _verifiedMeterData;

  @override
  void dispose() {
    _meterNumberController.dispose();
    _nicknameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
      _errorMessage = null;
    });
  }

  void _stopScanning() {
    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _processQRScanResult(String qrData) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      final result = await meterService.processQRScanResult(qrData);

      if (!mounted) return;

      if (result['is_valid']) {
        setState(() {
          _meterNumberController.text = result['meter_number'];
          _verifiedMeterData = result['meter_data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid QR code. Please try again.';
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

  Future<void> _verifyMeterNumber() async {
    if (_meterNumberController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a meter number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      final result = await meterService.processQRScanResult('INDOWATER:${_meterNumberController.text}');

      if (!mounted) return;

      if (result['is_valid']) {
        setState(() {
          _verifiedMeterData = result['meter_data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Invalid meter number. Please try again.';
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

  Future<void> _registerMeter() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meterService = Provider.of<MeterService>(context, listen: false);
      final result = await meterService.registerMeter(
        meterNumber: _meterNumberController.text,
        address: _addressController.text,
        nickname: _nicknameController.text,
      );

      if (!mounted) return;

      setState(() {
        _isSuccess = true;
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
    
    if (_isScanning) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: QRScanner(
          onScanSuccess: _processQRScanResult,
          onClose: _stopScanning,
        ),
      );
    }
    
    if (_isSuccess) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppTopBar(title: 'Add Meter'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Constants.waterSuccess,
                ),
                const SizedBox(height: Constants.marginLarge),
                Text(
                  'Meter Added Successfully!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Constants.waterSuccess,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.marginMedium),
                Text(
                  'Your meter has been successfully registered and is now ready to use.',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.marginLarge),
                AppButton(
                  text: 'View Meter Details',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.meterDetails,
                      arguments: {'meter_id': _verifiedMeterData?['id'].toString() ?? ''},
                    );
                  },
                  isFullWidth: true,
                  size: ButtonSize.large,
                ),
                const SizedBox(height: Constants.marginMedium),
                AppButton(
                  text: 'Back to Dashboard',
                  type: ButtonType.outline,
                  onPressed: () {
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
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Add Meter'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Constants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Instructions
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(width: Constants.marginSmall),
                          Text(
                            'How to Add a Meter',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Constants.marginMedium),
                      Text(
                        'You can add a meter by scanning the QR code on your water meter or by manually entering the meter number.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Constants.marginLarge),
                // Scan QR button
                AppButton(
                  text: 'Scan QR Code',
                  onPressed: _isLoading ? null : _startScanning,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  icon: Icons.qr_code_scanner,
                  size: ButtonSize.large,
                ),
                const SizedBox(height: Constants.marginMedium),
                Center(
                  child: Text(
                    'OR',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: Constants.marginMedium),
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
                // Meter number field with verify button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Meter Number',
                        hint: 'Enter meter number',
                        controller: _meterNumberController,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.water_drop,
                        validator: RequiredValidator(errorText: 'Meter number is required'),
                        enabled: !_isLoading && _verifiedMeterData == null,
                      ),
                    ),
                    const SizedBox(width: Constants.marginMedium),
                    SizedBox(
                      height: Constants.inputHeightMedium,
                      child: AppButton(
                        text: 'Verify',
                        onPressed: _isLoading || _verifiedMeterData != null ? null : _verifyMeterNumber,
                        isLoading: _isLoading,
                        size: ButtonSize.small,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Constants.marginMedium),
                // Verified meter info
                if (_verifiedMeterData != null) ...[
                  Container(
                    padding: const EdgeInsets.all(Constants.paddingMedium),
                    decoration: BoxDecoration(
                      color: Constants.waterSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Constants.waterSuccess,
                        ),
                        const SizedBox(width: Constants.marginSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meter Verified',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Constants.waterSuccess,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This meter is valid and ready to be registered',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Constants.marginLarge),
                ],
                // Nickname field
                AppTextField(
                  label: 'Meter Nickname (Optional)',
                  hint: 'E.g. Home, Office, etc.',
                  controller: _nicknameController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.label,
                  enabled: !_isLoading && _verifiedMeterData != null,
                ),
                const SizedBox(height: Constants.marginLarge),
                // Address field
                AppTextField(
                  label: 'Address',
                  hint: 'Enter meter location address',
                  controller: _addressController,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.location_on,
                  maxLines: 3,
                  validator: RequiredValidator(errorText: 'Address is required'),
                  enabled: !_isLoading && _verifiedMeterData != null,
                ),
                const SizedBox(height: Constants.marginLarge),
                // Register button
                AppButton(
                  text: 'Register Meter',
                  onPressed: _isLoading || _verifiedMeterData == null ? null : _registerMeter,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: ButtonSize.large,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}