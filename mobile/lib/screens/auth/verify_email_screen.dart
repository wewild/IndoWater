import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  Timer? _timer;
  int _resendCountdown = 0;
  String? _email;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserEmail();
      _startVerificationCheck();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getUserEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = await authProvider.getCurrentUser();
    if (user != null && user.email != null) {
      setState(() {
        _email = user.email;
      });
    }
  }

  void _startVerificationCheck() {
    // Check verification status every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkVerificationStatus();
    });
  }

  Future<void> _checkVerificationStatus() async {
    if (_isLoading || _isResending) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isVerified = await authProvider.checkEmailVerification();

      if (!mounted) return;

      if (isVerified) {
        _timer?.cancel();
        // Navigate to dashboard
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      // Silently handle error
      debugPrint('Error checking verification status: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resendVerificationEmail();

      if (!mounted) return;

      if (success) {
        // Start countdown for resend button
        setState(() {
          _resendCountdown = 60;
          _isResending = false;
        });

        // Start countdown timer
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_resendCountdown > 0) {
            setState(() {
              _resendCountdown--;
            });
          } else {
            timer.cancel();
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to resend verification email. Please try again.';
          _isResending = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isResending = false;
      });
    }
  }

  Future<void> _manuallyVerify() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _checkVerificationStatus();
      
      setState(() {
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.05),
                // Icon
                Icon(
                  Icons.mark_email_read,
                  size: 100,
                  color: theme.primaryColor,
                ),
                SizedBox(height: size.height * 0.03),
                // Title
                Text(
                  'Verify Your Email',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.marginMedium),
                // Subtitle
                Text(
                  'We have sent a verification email to:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Constants.marginMedium),
                // Email
                Text(
                  _email ?? 'your email address',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.03),
                // Instructions
                Container(
                  padding: const EdgeInsets.all(Constants.paddingMedium),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                    border: Border.all(
                      color: theme.dividerColor,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Please check your email and click on the verification link to complete your registration.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Constants.marginMedium),
                      Text(
                        'If you don\'t see the email, check your spam folder or click the resend button below.',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
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
                // Verify button
                AppButton(
                  text: 'I\'ve Verified My Email',
                  onPressed: _isLoading ? null : _manuallyVerify,
                  isLoading: _isLoading,
                  isFullWidth: true,
                  size: ButtonSize.large,
                ),
                const SizedBox(height: Constants.marginLarge),
                // Resend button
                AppButton(
                  text: _resendCountdown > 0
                      ? 'Resend Email (${_resendCountdown}s)'
                      : 'Resend Verification Email',
                  type: ButtonType.outline,
                  onPressed: _resendCountdown > 0 || _isResending ? null : _resendVerificationEmail,
                  isLoading: _isResending,
                  isFullWidth: true,
                ),
                const SizedBox(height: Constants.marginLarge),
                // Back to login
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                  },
                  child: Text(
                    'Back to Login',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}